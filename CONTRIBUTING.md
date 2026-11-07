# Como contribuir

Obrigado por querer melhorar o Miolo. Correções, traduções, novos formatos e relatos de problemas são bem-vindos.

> **English:** contributions in English are welcome too. Issues and pull requests can be written in either language.

## Relatar um problema

Abra uma [issue](https://github.com/luizfelipermoraes/miolo/issues) com:

- o que você esperava e o que aconteceu;
- as configurações usadas (o endereço da página guarda todas elas, então basta copiar o link);
- o PDF, ou pelo menos o número de páginas e o tamanho delas;
- onde você usou: navegador (e qual) ou app para Mac (e a versão do macOS).

Problemas de imposição ficam bem mais fáceis de achar com o [`example_page_numbers.pdf`](docs/example_page_numbers.pdf), que tem os números de 1 a 120 em tamanho grande.

## Preparar o ambiente

Precisa do [Node.js](https://nodejs.org) 18 ou mais novo e do [git](https://git-scm.com).

1. Faça um [fork](https://github.com/luizfelipermoraes/miolo/fork) e clone a sua cópia.
2. Instale as dependências e abra o servidor de desenvolvimento:

   ```bash
   npm install
   npm run dev
   ```

3. Abra http://localhost:5173/miolo/. O app recarrega sozinho a cada mudança.

Para o app para Mac, veja [App para Mac](README.md#app-para-mac) no README.

## Fazer a mudança

1. Crie um branch curto a partir do `main`: `feat/…` para recursos, `fix/…` para correções.
2. Escreva testes para comportamentos novos. Os testes rápidos ficam ao lado do código, em `src` (`*.test.js`).
3. Textos da interface ficam em [`src/locales/pt.json`](src/locales/pt.json) e [`src/locales/en.json`](src/locales/en.json). Toda chave nova precisa existir nos dois.
4. Antes de abrir o pull request, rode:

   ```bash
   npm run test:unit
   npm run lint
   npm run prettier
   ```

   `npm run lint:fix` e `npm run prettier:fix` corrigem o que der automaticamente.

5. Escreva mensagens de commit curtas e no imperativo, dizendo o que muda para quem usa (por exemplo, "Mostra a folha imposta no resumo").

## Abrir o pull request

- Abra contra o `main` deste repositório.
- Descreva o problema e como a mudança resolve. Para mudanças visuais, inclua uma captura de tela antes e depois.
- Confira se os testes do GitHub Actions passaram.

## Testes de PDF

Os testes em [`pdf-test`](pdf-test) imprimem PDFs completos e comparam com versões de referência usando o [pdf-visual-diff](https://github.com/moshensky/pdf-visual-diff). Rode com `npm run test:pdf`.

Para adicionar um caso:

1. Escolha um PDF da pasta `docs`, gere a imposição no app e guarde o `.zip`. Para formatos clássicos, use cadernos e frente e verso.
2. Copie o arquivo gerado (folha única) ou o primeiro caderno (formatos clássicos) para `pdf-test/files`, com um nome que descreva o caso.
3. Em `pdf-test/pdfTestCases.js`, adicione uma entrada em `testCases` com esse nome (sem `.pdf`), o `input` (o PDF de `docs`) e o `config` (o conteúdo do arquivo de configurações que vem no `.zip`).
4. Gere as referências com `npm run generate-snapshots`. Isso refaz todas elas, então confira o diff antes de enviar.

## Para quem mantém o projeto

### Branches

- **`main`**: sempre igual ao que está publicado.
- **Branches curtos** (`feat/…`, `fix/…`), apagados depois de entrar no `main`.
- **`gh-pages`**: o site gerado. Não edite à mão.

### Publicar o site

O workflow [`pages.yml`](.github/workflows/pages.yml) publica o site no `gh-pages` a cada push no `main`, quando as Actions estão ativadas. Para publicar à mão:

```bash
npm run build
git worktree add ../miolo-pages gh-pages
git -C ../miolo-pages rm -rq .
cp -R dist/. ../miolo-pages/ && touch ../miolo-pages/.nojekyll
git -C ../miolo-pages add -A && git -C ../miolo-pages commit -m "Publica o site"
git -C ../miolo-pages push origin gh-pages && git worktree remove ../miolo-pages
```

### Lançar uma versão

O site e o app para Mac usam a mesma versão, a do `package.json`.

1. Atualize `version` no `package.json` e faça o commit.
2. Gere o app e o instalador:

   ```bash
   sh macos/build.sh
   sh macos/dmg.sh
   ```

3. Crie a tag e a release com o `.dmg` anexado. O nome `Miolo.dmg` precisa ficar igual, porque o link de download do README aponta para ele:

   ```bash
   gh release create vX.Y.Z macos/build/Miolo.dmg --title "Miolo X.Y.Z" --notes "…"
   ```

O fundo da janela do `.dmg` é o [`macos/dmg-background.tiff`](macos/dmg-background.tiff), gerado a partir de [`macos/dmg-background.html`](macos/dmg-background.html) em 640 × 400 e no dobro, juntos com `tiffutil -cathidpicheck`.

O app tem assinatura local (ad hoc), então o macOS pede uma confirmação na primeira abertura. Para tirar esse passo, ele precisa ser assinado com um certificado Developer ID e notarizado pela Apple.

### Docker

O [`compose.yaml`](compose.yaml) gera o site e o serve com nginx, sem abrir portas: ele espera um servidor na frente. Para abrir uma porta, crie um `compose.override.yaml`:

```yaml
services:
  miolo-nginx:
    ports:
      - '80:80'
```

## Licença

Ao contribuir, você concorda que a sua contribuição seja distribuída sob a [Mozilla Public License 2.0](LICENSE), a mesma do projeto.
