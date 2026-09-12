local format = FORMAT

local function strip_accents(s)
  local map = {
    ["á"]="a", ["à"]="a", ["â"]="a", ["ã"]="a", ["ä"]="a",
    ["é"]="e", ["è"]="e", ["ê"]="e", ["ë"]="e",
    ["í"]="i", ["ì"]="i", ["î"]="i", ["ï"]="i",
    ["ó"]="o", ["ò"]="o", ["ô"]="o", ["õ"]="o", ["ö"]="o",
    ["ú"]="u", ["ù"]="u", ["û"]="u", ["ü"]="u",
    ["ç"]="c", ["Á"]="a", ["À"]="a", ["Â"]="a", ["Ã"]="a", ["Ä"]="a",
    ["É"]="e", ["È"]="e", ["Ê"]="e", ["Ë"]="e",
    ["Í"]="i", ["Ì"]="i", ["Î"]="i", ["Ï"]="i",
    ["Ó"]="o", ["Ò"]="o", ["Ô"]="o", ["Õ"]="o", ["Ö"]="o",
    ["Ú"]="u", ["Ù"]="u", ["Û"]="u", ["Ü"]="u",
    ["Ç"]="c",
  }
  for k,v in pairs(map) do s = s:gsub(k,v) end
  return s:lower()
end

local marker_map = { capitulo=1, secao=2, artigo=3, paragrafo=4, inciso=5, alinea=6 }

local function marker_to_header(block)
  local raw = pandoc.utils.stringify(block)
  local m, rest = raw:match("^%s*=([^%s]+)%s+(.+)$")
  if not m then return nil end
  local level = marker_map[strip_accents(m)]
  if not level then return nil end
  return pandoc.Header(level, pandoc.Str(rest))
end

local function preprocess_blocks(blocks)
  local out = {}
  for _, block in ipairs(blocks) do
    if block.t == "Para" then
      local h = marker_to_header(block)
      if h then table.insert(out, h) else table.insert(out, block) end
    else
      table.insert(out, block)
    end
  end
  return out
end

local function build_h4_context(blocks)
  local h4_group_size, cur_h3, h4_counts, block_h3 = {}, nil, {}, {}
  for i, block in ipairs(blocks) do
    if block.t == "Header" then
      if block.level == 3 then
        cur_h3 = i
        h4_counts[i] = 0
      elseif block.level == 4 and cur_h3 then
        h4_counts[cur_h3] = h4_counts[cur_h3] + 1
        block_h3[i] = cur_h3
      end
    end
  end
  for h4_idx, h3_idx in pairs(block_h3) do h4_group_size[h4_idx] = h4_counts[h3_idx] end
  return h4_group_size
end

local function to_roman(n)
  local vals = {{1000,"M"},{900,"CM"},{500,"D"},{400,"CD"},{100,"C"},{90,"XC"},{50,"L"},{40,"XL"},{10,"X"},{9,"IX"},{5,"V"},{4,"IV"},{1,"I"}}
  local r = ""
  for _, v in ipairs(vals) do while n >= v[1] do r = r .. v[2]; n = n - v[1] end end
  return r
end

local function ordinal_pt(n)
  return n < 10 and (tostring(n) .. "º") or tostring(n)
end

local function letter_pt(n)
  return string.char(96 + n) .. ")"
end

local function inciso_roman(n)
  return to_roman(n) .. " —"
end

local function reset(level, state)
  if level == 1 then state.sec, state.para, state.inc, state.ali, state.item = 0,0,0,0,0 end
  if level == 2 then state.para, state.inc, state.ali, state.item = 0,0,0,0 end
  if level == 3 then state.para, state.inc, state.ali, state.item = 0,0,0,0 end
  if level == 4 then state.inc, state.ali, state.item = 0,0,0 end
  if level == 5 then state.ali, state.item = 0,0 end
  if level == 6 then state.item = 0 end
end

local function render(doc)
  local blocks = preprocess_blocks(doc.blocks)
  local h4_group_size = build_h4_context(blocks)
  local state = {cap=0, sec=0, art=0, para=0, inc=0, ali=0, item=0}
  local out = {}

  if format:match("html") then
    table.insert(out, pandoc.RawBlock("html", [[
<style>
p.capitulo{text-align:center;font-weight:700;margin-top:1.5em;margin-bottom:.5em;text-transform:uppercase;line-height:1.4}
.capitulo-num{display:block;font-size:.9em;letter-spacing:.05em}
p.secao{text-align:center;font-weight:700;margin-top:1.2em;margin-bottom:.4em;line-height:1.4}
.secao-num{display:block;font-size:.9em}
p.artigo{margin-top:.8em;margin-bottom:.2em;text-indent:0;text-align:justify}
p.paragrafo{margin-top:.5em;margin-bottom:.2em;padding-left:2em;text-indent:-2em;text-align:justify}
p.inciso{margin-top:.4em;margin-bottom:.15em;padding-left:5em;text-indent:-2em;text-align:justify}
p.alinea{margin-top:.4em;margin-bottom:.15em;padding-left:5em;text-indent:-2em;text-align:justify}
ul.itens{list-style:none;padding-left:6.5em;margin:.15em 0}
li.item{text-align:justify;padding-left:1.5em;text-indent:-1.5em;margin-bottom:.1em}
</style>
]]))
  end

  for i, block in ipairs(blocks) do
    if block.t == "Header" then
      local text = pandoc.utils.stringify(block)
      if format == "latex" or format == "beamer" then
        if block.level == 1 then state.cap = state.cap + 1; reset(1, state); table.insert(out, pandoc.RawBlock("latex", "\\chapter{" .. text .. "}\n"))
        elseif block.level == 2 then state.sec = state.sec + 1; reset(2, state); table.insert(out, pandoc.RawBlock("latex", "\\section{" .. text .. "}\n"))
        elseif block.level == 3 then state.art = state.art + 1; reset(3, state); table.insert(out, pandoc.RawBlock("latex", "\\artigo " .. text .. "\n"))
        elseif block.level == 4 then
          if (h4_group_size[i] or 0) == 1 then table.insert(out, pandoc.RawBlock("latex", "\\paragrafounico " .. text .. "\n"))
          else state.para = state.para + 1; table.insert(out, pandoc.RawBlock("latex", "\\paragrafo " .. text .. "\n")) end
        elseif block.level == 5 then state.inc = state.inc + 1; table.insert(out, pandoc.RawBlock("latex", "\\inciso " .. text .. "\n"))
        elseif block.level == 6 then state.ali = state.ali + 1; table.insert(out, pandoc.RawBlock("latex", "\\alinea " .. text .. "\n")) end
      else
        if block.level == 1 then state.cap = state.cap + 1; reset(1, state); table.insert(out, pandoc.RawBlock("html", '<p class="capitulo"><span class="capitulo-num">CAPÍTULO ' .. to_roman(state.cap) .. '</span><br>' .. text .. '</p>\n'))
        elseif block.level == 2 then state.sec = state.sec + 1; reset(2, state); table.insert(out, pandoc.RawBlock("html", '<p class="secao"><span class="secao-num">Seção ' .. to_roman(state.sec) .. '</span><br>' .. text .. '</p>\n'))
        elseif block.level == 3 then state.art = state.art + 1; reset(3, state); table.insert(out, pandoc.RawBlock("html", '<p class="artigo"><strong>Art. ' .. ordinal_pt(state.art) .. '</strong>&nbsp;&nbsp;' .. text .. '</p>\n'))
        elseif block.level == 4 then
          if (h4_group_size[i] or 0) == 1 then table.insert(out, pandoc.RawBlock("html", '<p class="paragrafo paragrafo-unico"><span class="paragrafo-num">Parágrafo único.</span>&nbsp;' .. text .. '</p>\n'))
          else state.para = state.para + 1; table.insert(out, pandoc.RawBlock("html", '<p class="paragrafo"><span class="paragrafo-num">§ ' .. ordinal_pt(state.para) .. '</span>&nbsp;' .. text .. '</p>\n')) end
        elseif block.level == 5 then state.inc = state.inc + 1; table.insert(out, pandoc.RawBlock("html", '<p class="inciso"><span class="inciso-num">' .. inciso_roman(state.inc) .. '</span>&nbsp;' .. text .. '</p>\n'))
        elseif block.level == 6 then state.ali = state.ali + 1; table.insert(out, pandoc.RawBlock("html", '<p class="alinea"><span class="alinea-num">' .. letter_pt(state.ali) .. '</span>&nbsp;' .. text .. '</p>\n')) end
      end
    elseif block.t == "BulletList" then
      if format == "latex" or format == "beamer" then
        local raw = ""
        for _, item in ipairs(block.content) do
          local t = pandoc.utils.stringify(pandoc.Plain(item[1].content))
          raw = raw .. "\\itens " .. t .. "\n\n"
        end
        table.insert(out, pandoc.RawBlock("latex", raw))
      else
        local html = '<ul class="itens">\n'
        for _, item in ipairs(block.content) do
          state.item = state.item + 1
          local t = pandoc.utils.stringify(pandoc.Plain(item[1].content))
          html = html .. '  <li class="item"><span class="item-num">' .. tostring(state.item) .. '.</span> ' .. t .. '</li>\n'
        end
        table.insert(out, pandoc.RawBlock("html", html .. '</ul>\n'))
      end
    else
      table.insert(out, block)
    end
  end

  return pandoc.Pandoc(out, doc.meta)
end

function Pandoc(doc)
  return render(doc)
end
