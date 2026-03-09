# MediaPipe Build for aarch64 (Manylinux 2.28)

Este repositório contém a configuração necessária para realizar o build do **MediaPipe v0.10.32** em arquitetura **aarch64** (ARM64), utilizando como base o padrão Manylinux 2.28 para garantir compatibilidade com diversas distribuições Linux.

## 🚀 Por que este build é especial?

Realizar o build do MediaPipe em ARM não é uma tarefa trivial. Portamos o `Dockerfile.manylinux_2_28_x86_64` original para a arquitetura **aarch64** e aplicamos correções críticas em dependências que normalmente falham em ambientes de cross-compilação ou servidores ARM.

### Principais Alterações e Correções

#### 1. Eigen Local (Contorno ao bloqueio do GitLab)

O Eigen, uma dependência central, está hospedado no GitLab. O servidor do GitLab impõe uma verificação de bot que impede downloads via `curl` ou `wget` durante o build do Docker.

* **Solução:** Utilizamos um arquivo tarball do Eigen localmente.
* **Mapeamento Bazel:** Configuramos overrides no `.bazelrc` para que o Bazel aponte para o diretório `/opt/eigen` em vez de tentar baixar a biblioteca. Mapeamos os nomes `eigen`, `eigen3` e `eigen_archive` para cobrir todas as referências internas do MediaPipe e do TensorFlow.

#### 2. Fix de Analytics e Protobuf

Em sistemas ARM, certos cabeçalhos de telemetria (`mediapipe_log_extension.pb.h`) costumam não ser gerados corretamente, interrompendo o build.

* **Solução:** Implementamos um "fake build" para a pasta de analytics e utilizamos `sed` para remover as inclusões de log que não são essenciais para a execução do core da biblioteca.

#### 3. OpenCV Estático e Pathing

O build original muitas vezes busca bibliotecas estáticas (`.a`) em caminhos fixos de x86.

* **Solução:** Compilamos o OpenCV 4.10.0 via fonte dentro do container e ajustamos o arquivo `third_party/opencv_linux.BUILD` para realizar buscas via `glob` tanto em `lib` quanto em `lib64`, garantindo que o linker encontre os binários em sistemas ARM.

---

## 📂 Estrutura de Arquivos

* **`Dockerfile.manylinux_2_28_aarch64`**: Nosso arquivo principal de build. Ele é uma evolução do modelo x86_64, adaptado com as flags de arquitetura `armv8-a`, ajustes de caminhos de biblioteca e os patches de código descritos acima.
* **`build.sh`**: Script utilitário que automatiza o comando `docker build`. Ele configura as variáveis de ambiente necessárias (como o `PYTHON_BIN`) e inicia a compilação pesada.
* **`get_wheel_from_image.sh`**: Após o build, o arquivo `.whl` resultante fica "preso" dentro da imagem. Este script extrai o wheel da pasta `/wheelhouse/` do container para uma pasta local chamada `wheels/`, ajustando as permissões de usuário (UID/GID) para que você seja o dono do arquivo no host.

---

## 🛠️ Como usar

1. Certifique-se de que o arquivo `eigen-*.tar.gz` está na raiz deste diretório.
2. Inicie o build:
```bash
./build.sh

```


3. Após a conclusão (que pode levar um tempo considerável devido à compilação do Bazel e OpenCV), extraia o resultado:
```bash
./get_wheel_from_image.sh

```


4. O seu wheel pronto para instalação estará na pasta `./wheels`.

---

> **Nota:** Este build foi otimizado para rodar com o compilador `Clang` e utiliza o `Manylinux 2.28` para garantir que o binário funcione em sistemas Ubuntu modernos e outros derivados do RHEL/Debian em ARM64.


# ⏫ Atualizando a partir do repositório upstream (MediaPipe)

Este repositório é um fork de  
https://github.com/google-ai-edge/mediapipe

Periodicamente pode ser necessário atualizar o código do MediaPipe
mantendo os arquivos adicionais deste repositório (scripts de build,
Dockerfiles, etc.).

## Configurar o upstream (uma única vez)

Se o repositório original ainda não estiver configurado como `upstream`,
adicione-o:

```bash
git remote add upstream https://github.com/google-ai-edge/mediapipe.git
````

Verifique os remotes configurados:

```bash
git remote -v
```

O esperado é algo como:

```
origin    https://github.com/BS3D-BR/mediapipe.git
upstream  https://github.com/google-ai-edge/mediapipe.git
```

---

## Atualizar para a versão mais recente do upstream

Primeiro obtenha as atualizações do MediaPipe:

```bash
git fetch upstream
```

Depois integre as mudanças no branch principal deste repositório
(`main` ou `master`, dependendo da configuração):

```bash
git checkout main
git merge upstream/master
```

Resolva eventuais conflitos e então envie para o repositório da organização:

```bash
git push origin main
```

---

### Atualizar para uma *tag* específica do MediaPipe

Caso seja necessário alinhar este fork a uma versão específica do
MediaPipe (por exemplo `v0.10.32`):

Primeiro atualize as referências do upstream:

```bash
git fetch upstream --tags
```

Depois faça o merge da tag desejada:

```bash
git checkout main
git merge v0.10.32
```

ou explicitamente:

```bash
git merge upstream/tags/v0.10.32
```

Em seguida resolva eventuais conflitos e envie as mudanças:

```bash
git push origin main
```

---

### Observações

* Arquivos adicionais deste fork (como Dockerfiles, scripts ou wheels)
  permanecem preservados durante o merge.
* Conflitos podem ocorrer caso o upstream modifique arquivos que também
  tenham sido alterados neste repositório.
* Recomenda-se sempre revisar o resultado do merge antes de publicar as
  mudanças.

```

Se quiser, também posso te mostrar **um fluxo ainda mais seguro usado em forks grandes**, que cria um branch separado `upstream-sync` para testar o merge antes de atualizar o `main`. Isso evita quebrar o repositório quando o upstream muda algo grande (o que acontece bastante no MediaPipe).
```
