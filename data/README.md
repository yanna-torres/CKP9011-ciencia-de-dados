# Banco de Dados PostegresSQL

Este README contém as instruções para rodar localmente o banco de dados PostegreSQL usando Docker Compose.

## Pré-requisitos

Certifique-se de ter o Docker e o Docker Compose instalados:

- [Docker](https://www.docker.com/get-started)
- [Docker Compose](https://docs.docker.com/compose/install/)

## Arquivos

- `docker-compose.yml`: Define a configuração do PostegreSQL e insere os dados iniciais.
- `init.sql`: Script de inicialização do banco (instânciando a tabela e os dados).

## Como rodar?

1. Clone o repositório ou baixe os arquivos desta pasta.

    ```bash
    git clone https://github.com/yanna-torres/CKP9011-ciencia-de-dados.git
    git checkout lista-04
    cd CKP9011-ciencia-de-dados
    ```

2. Inicialize o serviço PostegreSQL

    Rode o seguinte comando com Docker Compose:

    ```bash
    docker-compose up -d
    ```

    Este comando vai:
    - Baixar a última versão da imagem do PostgreSQL
    - Criar e inicializar o container
    - Inicializar o banco de dados com o script presente em `init.sql`

3. Acesse o banco de dados

    O banco de dados PostgreSQL estará disponível em `localhost:5555`. Caso esta porta já esteja ocupada na sua máquina, atualize o arquivo `docker-compose.yml`.

    Para se conectar ao banco utilize as seguinte credenciais:
    - Username: CKP9011
    - Password: CKP9011
    - Database Name: fakeTelegram_db

4. Para parar o container

    Para parar o container, basta rodar o seguinte comando:
    
    ```bash
    docker-compose down
    ```

## Troubleshooting

1. Se o container não iniciar, olhe os logs utilizando o comando

    ```bash
    docker-compose logs
    ```

2. Verifique se o arquivo `init.sql` está formatado corretamente e os comando SQL estão certos.