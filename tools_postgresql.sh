#!/bin/bash

echo "Menu de Gerenciamento do PostgreSQL"
echo "1. Listar todos os usuários"
echo "2. Listar todos os bancos de dados"
echo "3. Listar todas as tabelas de um banco de dados específico"
echo "4. Atribuir função a um usuário"
echo "5. Mostrar quais usuários têm permissões em quais bancos de dados"
echo "6. Mostrar a quais bancos os usuários estão ligados"
echo "7. Remover permissão de um usuário a um banco de dados"
echo "8. Adicionar permissão de CONNECT a um usuário em um banco de dados"
echo "9. Criar usuário"
echo "10. Criar banco de dados"
echo "11. Conceder todas as permissões em um banco de dados para um usuário"
echo "12. Deletar usuário"
echo "13. Deletar banco de dados"
echo "14. Criar banco de dados com LC_COLLATE e LC_CTYPE 'pt_BR.UTF-8'"
echo "15. Sair"
echo -n "Selecione uma opção [1-15]: "
read OPTION

case $OPTION in
    1)
        echo "Listando todos os usuários..."
        sudo -u postgres psql -c "\du"
        ;;
    2)
        echo "Listando todos os bancos de dados..."
        sudo -u postgres psql -c "\l"
        ;;
    3)
        echo -n "Digite o nome do banco de dados para listar suas tabelas: "
        read DB_NAME
        echo "Listando todas as tabelas do banco de dados $DB_NAME..."
        sudo -u postgres psql -d $DB_NAME -c "\dt"
        ;;
    4)
        echo -n "Digite o nome do usuário para atribuir uma função: "
        read USER_NAME
        echo "Funções disponíveis: SUPERUSER, CREATEROLE, CREATEDB, REPLICATION, BYPASSRLS"
        echo -n "Digite a função a ser atribuída ao usuário $USER_NAME: "
        read ROLE
        sudo -u postgres psql -c "ALTER USER $USER_NAME WITH $ROLE;"
        ;;
    5)
        echo "Listando permissões de usuários em bancos de dados..."
        sudo -u postgres psql -c "SELECT datname, rolname FROM pg_database JOIN pg_roles ON pg_database.datdba = pg_roles.oid;"
        ;;
    6)
        echo "Mostrando a quais bancos de dados os usuários estão ligados..."
        sudo -u postgres psql -c "
        SELECT grantee, datname
        FROM pg_database
        JOIN pg_roles ON pg_database.datistemplate = false
        JOIN information_schema.role_table_grants ON (rolname = grantee)
        GROUP BY grantee, datname
        ORDER BY grantee, datname;"
        ;;
    7)
        echo -n "Digite o nome do banco de dados: "
        read DB_NAME
        echo -n "Digite o nome do usuário: "
        read USER_NAME
        echo "Removendo todas as permissões do usuário $USER_NAME no banco de dados $DB_NAME..."
        sudo -u postgres psql -d $DB_NAME -c "REVOKE ALL PRIVILEGES ON DATABASE \"$DB_NAME\" FROM $USER_NAME;"
        ;;
    8)
        echo -n "Digite o nome do banco de dados: "
        read DB_NAME
        echo -n "Digite o nome do usuário: "
        read USER_NAME
        echo "Adicionando permissão de CONNECT ao usuário $USER_NAME no banco de dados $DB_NAME..."
        sudo -u postgres psql -c "GRANT CONNECT ON DATABASE \"$DB_NAME\" TO $USER_NAME;"
        ;;
    9)
        echo -n "Digite o nome do novo usuário: "
        read NEW_USER
        echo -n "Digite a senha para o novo usuário: "
        read -s NEW_PASS
        echo
        sudo -u postgres psql -c "CREATE USER $NEW_USER WITH PASSWORD '$NEW_PASS';"
        echo "Usuário $NEW_USER criado."
        ;;
    10)
        echo -n "Digite o nome do novo banco de dados: "
        read NEW_DB
        sudo -u postgres psql -c "CREATE DATABASE $NEW_DB;"
        echo "Banco de dados $NEW_DB criado."
        ;;
    11)
        echo -n "Digite o nome do banco de dados: "
        read DB_NAME
        echo -n "Digite o nome do usuário: "
        read USER_NAME
        echo "Concedendo todas as permissões no banco de dados $DB_NAME para o usuário $USER_NAME..."
        sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE \"$DB_NAME\" TO $USER_NAME;"
        ;;
    12)
        echo -n "Digite o nome do usuário a ser deletado: "
        read DEL_USER
        echo "Deletando usuário $DEL_USER..."
        sudo -u postgres psql -c "DROP USER $DEL_USER;"
        ;;
    13)
        echo -n "Digite o nome do banco de dados a ser deletado: "
        read DEL_DB
        echo "Deletando banco de dados $DEL_DB..."
        sudo -u postgres psql -c "DROP DATABASE $DEL_DB;"
        ;;
    14)
        echo -n "Digite o nome do novo banco de dados: "
        read NEW_DB
        echo "Criando banco de dados $NEW_DB com LC_COLLATE e LC_CTYPE 'pt_BR.UTF-8'..."
        sudo -u postgres psql -c "CREATE DATABASE \"$NEW_DB\" WITH LC_COLLATE='pt_BR.UTF-8' LC_CTYPE='pt_BR.UTF-8' TEMPLATE=template0;"
        echo "Banco de dados $NEW_DB criado com sucesso."
        ;;
    15)
        echo "Saindo..."
        exit 0
        ;;
    *)
        echo "Opção inválida."
        ;;
esac
