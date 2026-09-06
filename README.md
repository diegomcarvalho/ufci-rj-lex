# ufci-rj-lex

[![Quarto](https://img.shields.io/badge/Quarto-%3E%3D1.7.24-blue)](https://quarto.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

**ufci-rj-lex** é uma extensão do Quarto para a geração de normas e regulamentos técnico-institucionais no padrão visual da **UFCI/RJ**. O formato é baseado na classe LaTeX `br-lex`, compilada com LuaLaTeX, e suporta saída em **PDF** (padrão A-2b) e **HTML**.

---

## Pré-requisitos

| Ferramenta | Versão mínima |
|---|---|
| [Quarto](https://quarto.org/docs/download/) | ≥ 1.7.24 |
| [LuaLaTeX](https://www.tug.org/texlive/) | TexLive 2023+ ou MiKTeX |
| Fontes: Sofia Sans Condensed, Roboto, Roboto Mono | Instaladas no sistema |

---

## Instalação

### Novo documento (recomendado)

Use o template diretamente para criar um novo projeto:

```bash
quarto use template diegomcarvalho/ufci-rj-lex
```

Isso instala a extensão e cria o arquivo `template.qmd` como ponto de partida.

### Projeto existente

Para adicionar o formato a um projeto Quarto já existente:

```bash
quarto add diegomcarvalho/ufci-rj-lex
```

---

## Uso rápido

Após a instalação, renderize o documento com:

```bash
# Gerar PDF (padrão)
quarto render meu-relatorio.qmd --to clx-pdf

# Gerar HTML
quarto render meu-relatorio.qmd --to clx-html

# Gerar ambos
quarto render meu-relatorio.qmd
```

---

## Estrutura do YAML (cabeçalho do `.qmd`)

O cabeçalho YAML controla todos os metadados e as opções de formatação do documento. Abaixo está a referência completa de cada parâmetro:

### Metadados do documento

```yaml
---
title: "Título do Regulamento"
description: "Descrição da norma"
author: Diego Carvalho
header: "Pró-reitoria de Gestão Estratégica e Tecnologia da Informação"
date: "06/18/2026"
format:
  clx-html: default
  clx-pdf:
    keep-tex: false
    classoption: [paragrafoespaco,capitulo]
---
```

| Parâmetro | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `title` | string | ✅ | Título principal do documento |
| `date` | string | ✅ | Data de publicação (texto livre) |
| `header` | string |  | Unidade administrativa que aparece no cabeçalho |
| `description` | string |  | Descritivo da norma |


### Formato de saída

```yaml
format:
  clx-html: default
  clx-pdf:
    keep-tex: false
    classoption: [paragrafoespaco,capitulo]
```

| Opção `classoption` | Descrição |
|---|---|
| `keep-tex` | Não remove o arquivo LaTeX depois da compilação |
| `capitulo` | Faz os capítulos começarem na mesma página |
| `paragrafoespaco` | Controla o espaçamento |


---

## Recursos do Markdown suportados

O template suporta toda a sintaxe Markdown padrão do Quarto, incluindo:

- **Negrito**, *itálico*, `código inline`
- Tabelas GFM
- Notas de rodapé `[^1]`
- Equações LaTeX inline `\( x^2 \)` e em bloco `\[ E = mc^2 \]`
- Callouts Quarto: `:::{.callout-note}` etc.

Mapeamento de headings:

| Markdown | Elemento | Saída LaTeX / HTML |
|---|---|---|
| H1 (`#`) | Capítulo | `\chapter` / `<p class="capitulo">` |
| H2 (`##`) | Seção | `\section` / `<p class="secao">` |
| H3 (`###`) | Artigo | `\artigo` / `<p class="artigo">` |
| H4 (`####`) | Parágrafo | `\paragrafo` ou `\paragrafounico` / `<p class="paragrafo">` |
| H5 (`#####`) | Alínea | `\alinea` / `<p class="alinea">` |
| Listas ordenadas | Incisos | `\inciso` / `<p class="inciso">` |


---

## Licença

Distribuído sob a licença [MIT](LICENSE). © 2026 Diego Carvalho — UFCI/RJ.