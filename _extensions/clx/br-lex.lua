-- br-lex.lua
-- Filtro Quarto/Pandoc para estrutura de lei brasileira (MRPR + br-lex.cls)
--
-- Mapeamento de headings:
--   H1  -> Capítulo   (\chapter      / <p class="capitulo">)
--   H2  -> Seção      (\section      / <p class="secao">)
--   H3  -> Artigo     (\artigo       / <p class="artigo">)
--   H4  -> Parágrafo  (\paragrafo ou \paragrafounico / <p class="paragrafo">)
--   H5  -> Alínea     (\alinea       / <p class="alinea">)
--
-- Mapeamento de listas:
--   UL após H3/H4 -> Incisos  (\inciso  / <ul class="incisos">)
--   UL após H5    -> Itens    (\itens   / <ul class="itens-alinea">)
--
-- Regra MRPR: \paragrafounico quando há exatamente 1 H4 após um H3.

local format = FORMAT

-----------------------------------------------------------------------
-- Pré-processamento
-----------------------------------------------------------------------
local function build_context(blocks)
    local h4_group_size     = {} -- h4_group_size[h4_idx] = nº de H4s no grupo do H3 pai
    local ul_context        = {} -- ul_context[ul_idx]    = "inciso" | "alinea"

    local cur_h3            = nil
    local h4_counts         = {} -- h4_counts[h3_idx]
    local block_h3          = {} -- block_h3[h4_idx] = h3_idx

    local cur_heading_level = nil

    for i, block in ipairs(blocks) do
        if block.t == "Header" then
            local lvl = block.level
            cur_heading_level = lvl

            if lvl == 3 then
                cur_h3 = i
                h4_counts[i] = 0
            elseif lvl == 4 then
                if cur_h3 then
                    h4_counts[cur_h3] = h4_counts[cur_h3] + 1
                    block_h3[i] = cur_h3
                end
            end
        elseif block.t == "BulletList" then
            if cur_heading_level == 5 then
                ul_context[i] = "inciso" -- DC, it was alinea
            else
                ul_context[i] = "inciso"
            end
        end
    end

    for h4_idx, h3_idx in pairs(block_h3) do
        h4_group_size[h4_idx] = h4_counts[h3_idx]
    end

    return h4_group_size, ul_context
end

-----------------------------------------------------------------------
-- Utilitários
-----------------------------------------------------------------------
local function to_roman(n)
    local vals = {
        { 1000, "M" }, { 900, "CM" }, { 500, "D" }, { 400, "CD" },
        { 100,  "C" }, { 90, "XC" }, { 50, "L" }, { 40, "XL" },
        { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" }
    }
    local r = ""
    for _, v in ipairs(vals) do
        while n >= v[1] do
            r = r .. v[2]; n = n - v[1]
        end
    end
    return r
end

local function ordinal_pt(n)
    return n < 10 and (tostring(n) .. "º") or tostring(n)
end

local function roman_upper(n)
    -- capítulos e seções em romano maiúsculo
    return to_roman(n)
end

local function alinea_label(n)
    return string.char(96 + n) .. ")"
end

-----------------------------------------------------------------------
-- Estado global
-----------------------------------------------------------------------
local h4_group_size = {}
local ul_context    = {}

-- contadores HTML
local cap_n         = 0
local sec_n         = 0
local art_n         = 0
local para_n        = 0
local alin_n        = 0
local inc_n         = 0
local item_n        = 0

local function reset_on_capitulo()
    sec_n = 0; para_n = 0; alin_n = 0; inc_n = 0; item_n = 0
end
local function reset_on_secao()
    para_n = 0; alin_n = 0; inc_n = 0; item_n = 0
end
local function reset_on_artigo()
    para_n = 0; alin_n = 0; inc_n = 0; item_n = 0
end
local function reset_on_para()
    alin_n = 0; inc_n = 0; item_n = 0
end
local function reset_on_alinea() item_n = 0 end

-----------------------------------------------------------------------
-- LaTeX
-----------------------------------------------------------------------
local function latex_header(block, idx)
    local text = pandoc.utils.stringify(block)
    local lvl  = block.level

    if lvl == 1 then
        return pandoc.RawBlock("latex", "\\chapter{" .. text .. "}\n")
    elseif lvl == 2 then
        return pandoc.RawBlock("latex", "\\section{" .. text .. "}\n")
    elseif lvl == 3 then
        return pandoc.RawBlock("latex", "\\artigo " .. text .. "\n")
    elseif lvl == 4 then
        local gs = h4_group_size[idx] or 0
        if gs == 1 then
            return pandoc.RawBlock("latex", "\\paragrafounico " .. text .. "\n")
        else
            return pandoc.RawBlock("latex", "\\paragrafo " .. text .. "\n")
        end
    elseif lvl == 5 then
        return pandoc.RawBlock("latex", "\\alinea " .. text .. "\n")
    end

    return block
end

local function latex_bullet_list(block, idx)
    local ctx = ul_context[idx] or "inciso"
    local cmd = (ctx == "alinea") and "\\itens" or "\\inciso"
    local raw = ""
    for _, item in ipairs(block.content) do
        local t = pandoc.utils.stringify(pandoc.Plain(item[1].content))
        raw = raw .. cmd .. " " .. t .. "\n\n"
    end
    return pandoc.RawBlock("latex", raw)
end

-----------------------------------------------------------------------
-- HTML
-----------------------------------------------------------------------
local function html_header(block, idx)
    local text = pandoc.utils.stringify(pandoc.Span(block.content))
    local lvl  = block.level

    if lvl == 1 then
        cap_n = cap_n + 1
        reset_on_capitulo()
        return pandoc.RawBlock("html",
            '<p class="capitulo">' ..
            '<span class="capitulo-num">CAPÍTULO ' .. roman_upper(cap_n) .. '</span><br>' ..
            text .. '</p>\n')
    elseif lvl == 2 then
        sec_n = sec_n + 1
        reset_on_secao()
        return pandoc.RawBlock("html",
            '<p class="secao">' ..
            '<span class="secao-num">Seção ' .. roman_upper(sec_n) .. '</span><br>' ..
            text .. '</p>\n')
    elseif lvl == 3 then
        art_n = art_n + 1
        reset_on_artigo()
        return pandoc.RawBlock("html",
            '<p class="artigo"><strong>Art. ' .. ordinal_pt(art_n) ..
            '</strong>&nbsp;&nbsp;' .. text .. '</p>\n')
    elseif lvl == 4 then
        reset_on_para()
        local gs = h4_group_size[idx] or 0
        if gs == 1 then
            return pandoc.RawBlock("html",
                '<p class="paragrafo paragrafo-unico">' ..
                '<span class="paragrafo-num">Parágrafo único.</span>&nbsp;' ..
                text .. '</p>\n')
        else
            para_n = para_n + 1
            return pandoc.RawBlock("html",
                '<p class="paragrafo">' ..
                '<span class="paragrafo-num">§ ' .. ordinal_pt(para_n) ..
                '</span>&nbsp;' .. text .. '</p>\n')
        end
    elseif lvl == 5 then
        reset_on_alinea()
        alin_n = alin_n + 1
        return pandoc.RawBlock("html",
            '<p class="alinea">' ..
            '<span class="alinea-num">' .. alinea_label(alin_n) ..
            '</span>&nbsp;' .. text .. '</p>\n')
    end

    return block
end

local function html_bullet_list(block, idx)
    local ctx = ul_context[idx] or "inciso"

    if ctx == "alinea" then
        local html = '<ul class="itens-alinea">\n'
        for _, item in ipairs(block.content) do
            item_n = item_n + 1
            local t = pandoc.utils.stringify(pandoc.Plain(item[1].content))
            html = html ..
                '  <li class="item-alinea"><span class="item-num">' ..
                tostring(item_n) .. '.</span> ' .. t .. '</li>\n'
        end
        return pandoc.RawBlock("html", html .. '</ul>\n')
    else
        local html = '<ul class="incisos">\n'
        for _, item in ipairs(block.content) do
            inc_n = inc_n + 1
            local t = pandoc.utils.stringify(pandoc.Plain(item[1].content))
            html = html ..
                '  <li class="inciso"><span class="inciso-num">' ..
                to_roman(inc_n) .. ' —</span> ' .. t .. '</li>\n'
        end
        return pandoc.RawBlock("html", html .. '</ul>\n')
    end
end

-----------------------------------------------------------------------
-- CSS
-----------------------------------------------------------------------
local css_block = pandoc.RawBlock("html", [[
<style>
/* ===== br-lex: Formatação de lei brasileira (MRPR) ===== */

/* Capítulo: centralizado, maiúsculas, negrito */
p.capitulo {
  text-align: center;
  font-weight: bold;
  margin-top: 1.5em;
  margin-bottom: 0.5em;
  text-transform: uppercase;
  line-height: 1.4;
}
.capitulo-num {
  display: block;
  font-size: 0.9em;
  letter-spacing: 0.05em;
}

/* Seção: centralizado, negrito, sem maiúsculas forçadas */
p.secao {
  text-align: center;
  font-weight: bold;
  margin-top: 1.2em;
  margin-bottom: 0.4em;
  line-height: 1.4;
}
.secao-num {
  display: block;
  font-size: 0.9em;
}

/* Artigo */
p.artigo {
  margin-top: 0.8em;
  margin-bottom: 0.2em;
  text-indent: 0;
  text-align: justify;
}
p.artigo strong { font-weight: bold; }

/* Parágrafo: recuo 2em, símbolo § */
p.paragrafo {
  margin-top: 0.5em;
  margin-bottom: 0.2em;
  padding-left: 2em;
  text-indent: -2em;
  text-align: justify;
}
.paragrafo-num { margin-right: 0.4em; }

/* Alínea: recuo 5em */
p.alinea {
  margin-top: 0.4em;
  margin-bottom: 0.15em;
  padding-left: 5em;
  text-indent: -2em;
  text-align: justify;
}
.alinea-num { margin-right: 0.4em; }

/* Incisos: lista sem marcador, romano */
ul.incisos {
  list-style: none;
  padding-left: 2em;
  margin: 0.2em 0;
}
li.inciso {
  text-align: justify;
  padding-left: 2em;
  text-indent: -2em;
  margin-bottom: 0.15em;
}
.inciso-num { margin-right: 0.4em; }

/* Itens de alínea: arábicos */
ul.itens-alinea {
  list-style: none;
  padding-left: 6.5em;
  margin: 0.15em 0;
}
li.item-alinea {
  text-align: justify;
  padding-left: 1.5em;
  text-indent: -1.5em;
  margin-bottom: 0.1em;
}
.item-num { margin-right: 0.4em; }
</style>
]])

-----------------------------------------------------------------------
-- Ponto de entrada: Pandoc()
-----------------------------------------------------------------------
function Pandoc(doc)
    h4_group_size, ul_context = build_context(doc.blocks)

    local new_blocks = {}
    if format:match("html") then
        table.insert(new_blocks, css_block)
    end

    for i, block in ipairs(doc.blocks) do
        if block.t == "Header" then
            if format == "latex" or format == "beamer" then
                table.insert(new_blocks, latex_header(block, i))
            elseif format:match("html") then
                table.insert(new_blocks, html_header(block, i))
            else
                table.insert(new_blocks, block)
            end
        elseif block.t == "BulletList" then
            if format == "latex" or format == "beamer" then
                table.insert(new_blocks, latex_bullet_list(block, i))
            elseif format:match("html") then
                table.insert(new_blocks, html_bullet_list(block, i))
            else
                table.insert(new_blocks, block)
            end
        else
            table.insert(new_blocks, block)
        end
    end

    return pandoc.Pandoc(new_blocks, doc.meta)
end
