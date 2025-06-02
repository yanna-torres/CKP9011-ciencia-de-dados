# Lista 04 - Análise Exploratória de Dados

>Yanna Torres Gonçalves
>
>Matrícula: 587299
>
>Mestrado em Ciências da Computação

## Objetivo
Exercitar os conceitos referente à análise exploratória de dados

## Vídeo de Apresentação (Youtube)


## Resolução

As visualizações criadas com o Metabase podem ser encontradas no arquivo [Lista04_metabase.pdf](Lista04_metabase.pdf)

As próximas seções contêm as instruções para rodar localmente o banco de dados PostegreSQL e o Metabase usando Docker Compose.

### Pré-requisitos

Certifique-se de ter o Docker e o Docker Compose instalados:

- [Docker](https://www.docker.com/get-started)
- [Docker Compose](https://docs.docker.com/compose/install/)

### Arquivos

- `docker-compose.yml`: Define a configuração do PostegreSQL e insere os dados iniciais.
- `init.sql`: Script de inicialização do banco (instânciando a tabela e os dados).

### Como rodar?

1. Clone o repositório ou baixe os arquivos desta pasta.

    ```bash
    git clone https://github.com/yanna-torres/CKP9011-ciencia-de-dados.git
    git checkout lista-04
    cd CKP9011-ciencia-de-dados
    ```

2. Inicialize os serviços

    Rode o seguinte comando com Docker Compose:

    ```bash
    cd data
    docker-compose up -d
    ```

    Este comando vai:
    - Baixar a última versão da imagem do PostgreSQL
    - Criar e inicializar o container
    - Inicializar o banco de dados com o script presente em `init.sql`
    - Baixar a última versão do Metabase
    - Inicializar o Metabase

3. Acesse o banco de dados

    O banco de dados PostgreSQL estará disponível em `localhost:5555`. Caso esta porta já esteja ocupada na sua máquina, atualize o arquivo `docker-compose.yml`.

    Para se conectar ao banco utilize as seguinte credenciais:
    - Username: CKP9011
    - Password: CKP9011
    - Database Name: fakeTelegram_db
  
4. Acesse o Metabase

    O Metabase estará disponível em `localhost:3000`. Caso esta porta já esteja ocupada, atualize o `docker-compose.yml`.

    Para conectar o banco ao Metabase basta definir o host como `host.docker.internal` e utilizar as credenciais já mencionadas.

    Após isso, seu Metabase irá conter todos os dados e será possível criar dashboards.

5. Para parar o container

    Para parar o container, basta rodar o seguinte comando:
    
    ```bash
    docker-compose down
    ```

### Troubleshooting

1. Se o container não iniciar, olhe os logs utilizando o comando

    ```bash
    docker-compose logs
    ```

2. Verifique se o arquivo `init.sql` está formatado corretamente e os comando SQL estão certos.

3. Caso não exista dados, verifique se o arquivo fakeTelegramBR_2022_clean.csv foi baixado corretamente.
