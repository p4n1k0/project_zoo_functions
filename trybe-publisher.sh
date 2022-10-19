#!/bin/bash

Help()
{
   # Display Help
   printf "Script para limpeza de conteúdo de propriedade intelectual da Trybe \n"
   printf "Sintaxe: trybe-publisher [-b | -p | -r | -d | -h] \n"
   printf "opções(com * são obrigatórias): \n"
   printf "  -b(branch)         * Nome da sua branch no repositório original\n"
   printf "  -p(projeto)        * Nome do novo repositório que será criado em seu GitHub\n"
   printf "  -r(remote novo)     Nome do novo remote (padrão: origin)\n"
   printf "  -d(descrição)      Descrição do projeto em seu repositório (padrão: vazio)\n"
   printf "  -h(help)           Mostra esta mensagem de ajuda\n"
   printf "  --private          Define o novo repositório como privado (padrão: público)\n"
   exit 0
}

#-----Recupera e define parâmetros-------

REPO_PRIVATE=false

# ref --args: https://stackoverflow.com/a/7680682/12763774
allopts="hb:p:r:d:-:"
while getopts "$allopts" option;
do
    case "${option}"
        in
            -)
                case "${OPTARG}" in
                    private) REPO_PRIVATE=true;;
                    *)
                        if [ "$OPTERR" = 1 ] && [ "${allopts:0:1}" != ":" ]; then
                            echo "Comando inválido --${OPTARG}" >&2
                        fi
                        ;;
                esac;;
            h) Help;;
            b) USER_BRANCH=${OPTARG};;
            p) REPO_NAME=${OPTARG};;
            r) REMOTE_NAME=${OPTARG};;
            d) DESCR=${OPTARG};;
            \?) echo "" && Help && exit 1;;
    esac
done

# define o valor padrão para o parâmetro '-r' 
[[ -z $REMOTE_NAME ]] && REMOTE_NAME="project-temp-remote-name"

#-----Códigos ANSI para cores no terminal-------

CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NO_COLOR='\033[0m'
echo -e "${NO_COLOR}" &> /dev/null

#-----Verificações iniciais-------

# verifica se a pessoa possui o gh-cli
if ! [[ -x $(command -v gh) ]] || ! gh auth status >/dev/null 2>&1; # ref https://stackoverflow.com/a/73465507/12763774
then
    echo 
    echo -e "${RED}Você precisa da ferramenta github-cli(gh) instalada e autenticada na sua conta para continuar."
    echo 
    exit 1
fi

# verifica se possui o git-filter-repo
if ! [[ -x $(command -v git-filter-repo) ]];
then
    read -p "Você deseja executar o script de instalação do git-filter-repo? (S/n)" -n 1 -r
    [[ $REPLY =~ ^[Nn]$ ]] && echo -e "${BR}${CYAN}Tudo bem, encerrando sem fazer nada!${BR}" && exit 1
    gh repo clone newren/git-filter-repo
    MV_RESULT=$(sudo mv git-filter-repo/git-filter-repo /usr/local/bin && echo ok)
    [[ "$MV_RESULT" != "ok" ]] && sudo mkdir /usr/local/bin && sudo mv git-filter-repo/git-filter-repo /usr/local/bin
    rm -rf git-filter-repo
fi

# verifica se os parâmetros de 'branch' e 'novo repositório' foram definindos 
if [[ -z $USER_BRANCH ]] || [[ -z $REPO_NAME ]]; then
    echo
    echo -e "${RED}Os parâmetros -b 'nome_na_branch' e -p 'nome_do_novo_repositorio' são obrigatórios."
    echo
    exit 1
fi

if [[ $REPO_NAME = *" "* ]]; then
    echo
    echo -e "${RED}O nome ${NO_COLOR} '$REPO_NAME' ${RED} escolhido para o novo repositório não pode conter espaços.${NO_COLOR}"
    echo
    exit 1
fi

# verifica se repositório desejado já existe

GH_USERNAME=$(gh api user -q '.login')
REPO_LIST=($(gh repo list --json 'name' -q '.[].name' -L 1000))
if [[ " ${REPO_LIST[*]} " =~ " ${REPO_NAME} " ]]; then
    echo
    echo -e "${RED}O nome escolhido para o novo repositório já está em uso."
    echo
    exit 1
fi

# verifica se a pasta atual é um repositório git da trybe com origin apontando para o tryber
IS_GIT_REPO=$(git rev-parse --is-inside-work-tree)
IS_ORIGIN_TRYBE_REMOTE=$(git remote get-url origin | grep "tryber" || false)
if [[ ! $IS_GIT_REPO || ! $IS_ORIGIN_TRYBE_REMOTE ]]; 
then 
    echo -e "${RED}Você precisa estar em uma pasta com repositório git de um projeto da trybe para iniciar o script.${NO_COLOR}"
    exit 1
fi

#-----Script start--------

current_folder=${PWD##*/}
current_project=$(echo "$current_folder" | sed -r 's/(sd-([0-9]{1,3}|xp)-([a-z]-)?)(.*)/\4/')

#-----Define branch que será publicada--------

if [[ $USER_BRANCH == *"group"* ]]; then
  string=$(git branch -a | grep "$USER_BRANCH$") # acha as branches com o nome definido nos parâmetros caso haja "group" no nome
else
  string=$(git branch -a | grep "$USER_BRANCH") # acha as branches com o nome definido nos parâmetros  
fi

BRANCHES=$(echo "$string" | sed -r 's/(remotes\/origin\/)(.*)/\2/')

if [[ ! $BRANCHES ]] ; then
  echo "branch não encontrada, encerrando script."
  exit 1
fi

array=($(echo "$BRANCHES" | tr '\n' '\n')) # quebra a estrutura do git branch -a em um array

if [[ "$OSTYPE" != *"linux"* ]]; then
    TARGET_BRANCH=${array[$((${#array[@]} - 1))]} # caso não seja linux ref: https://stackoverflow.com/a/61004126
else
    TARGET_BRANCH=${array[-1]} # pega o nome da branch (que é o último elemento do array) caso seja linux
fi

#------- Boas-vindas e confirmação de intenção

echo -e "${GREEN}* * * * * * * * * * * * * * * * * *${NO_COLOR}"
echo    "Boas-vindas ao script de "
echo -e "publicação de projetos da ${GREEN}Trybe"
echo -e "* * * * * * * * * * * * * * * * * *${NO_COLOR}"
echo
echo -e "${RED}NÃO RECOMENDAMOS utilizar esse"
echo "script ANTES de receber a aprovação"
echo -e "no projeto.${NO_COLOR}"
echo 
echo "Esse script irá fazer um push da"
echo -e "branch: ${GREEN}${TARGET_BRANCH}${NO_COLOR}"
echo -e "do projeto: ${CYAN}${current_folder}${NO_COLOR}"
echo 
if $REPO_PRIVATE
then
    echo -e "ao seguinte repositório ${RED}privado${NO_COLOR} que será criado:"
else
    echo -e "ao seguinte repositório ${RED}público${NO_COLOR} que será criado:"
fi
echo -e "${GREEN}https://github.com/${GH_USERNAME}/${REPO_NAME}${NO_COLOR}"
echo
read -p "Tem certeza que deseja prosseguir? (N/s)" -n 1 -r
echo
echo "- - - - - - - - - - - - - - - - - -"
[[ ! $REPLY =~ ^[Ss]$ ]] && echo "Entendido! Nada será feito :)" && exit 1

#------- Clona e/ou atualiza o repositório de scripts

SCRIPTS_BASE="$HOME/.student-repo-publisher" &&
if [[ ! -d $SCRIPTS_BASE ]]; then  
    git clone git@github.com:tryber/student-repo-publisher.git $SCRIPTS_BASE # clona o repo da trybe com os scripts de limpeza de projeto se não tiver clonado já
else
    CURR_PATH=$(pwd)
    cd $SCRIPTS_BASE && git pull origin main --quiet # caso o repositório já exista, sincroniza qualquer atualização
    cd "$CURR_PATH" # retorna para a pasta inicial independente de erro
fi


#------- Entra na branch que será trabalhada

git checkout $TARGET_BRANCH --quiet && #dá checkout

#------- Recupera o script correto baseado no projeto atual

if [[ $(find . -type f -name trybe-filter-repo.sh | head -n 1) ]] ; then
    echo -e "${CYAN}Script para este projeto está disponível!${NO_COLOR}"
else
    if [[ $(find $SCRIPTS_BASE/repo-filters-by-project/ -type d -name "*$current_project" | head -n 1) ]] ; then
        echo -e "${CYAN}Script para este projeto foi encontrado no repositório base!${NO_COLOR}"
        cp $SCRIPTS_BASE/repo-filters-by-project/*$current_project/trybe-filter-repo.sh ./
    else
        echo -e "${BR}${YELLOW}Não foi encontrado o script para o projeto ${current_project}!${NO_COLOR}${BR}"
        read -p "Você deseja prosseguir, se comprometendo a apagar os arquivos sensíveis da Trybe manualmente? (N/s)" -n 1 -r
        echo
        echo "- - - - - - - - - - - - - - - - - -"
        
        [[ ! $REPLY =~ ^[Ss]$ ]] && echo -e "${BR}${CYAN}Tudo bem, encerrando! Nada será feito${BR}" && exit 1
        
        cp $SCRIPTS_BASE/trybe-filter-repo.sh ./
    fi
    git add trybe-filter-repo.sh && git commit -m "add trybe-filter-repo.sh" --quiet
fi

#-------Sincronizando o remoto com o local ------------

HAS_LOCAL_MODS=$(git status --porcelain)
if [[ $HAS_LOCAL_MODS ]]; then
    echo "Existem modificações locais não commitadas pendentes na sua branch, não é possível continuar."
    git status
    exit 1
fi  

if ! git fetch origin --quiet ; then # não tem acesso ou porque não existe ou porque não tem autorização
    echo -e "${CYAN}O script usará os arquivos ${NO_COLOR}locais${CYAN}."
    echo "Obs: isso acontece porque esse repositório não existe ou você não tem autorização para acessá-lo mais${BR}."
else
    # se tem acesso ao remote, dá um fetch e verifica se existe diferença entre local/remoto com git diff $branch origin/$branch
    HAS_REMOTE_MODS=$(git diff --stat $TARGET_BRANCH origin/$TARGET_BRANCH)

    if [[ $HAS_REMOTE_MODS ]]; then
        echo -e "${YELLOW}Existe alguma diferença entre o repositório remoto e o local.${NO_COLOR}"
        read -p "Você deseja atualizar a branch local (git pull)? (N/s)" -n 1 -r
        echo
        echo "- - - - - - - - - - - - - - - - - -"
        if [[ $REPLY =~ ^[Ss]$ ]]; then
            git pull origin $TARGET_BRANCH #pega todas as modificações da branch remota
        else
            echo 
            echo -e "${BR}${CYAN}Tudo bem, o script usará os arquivos ${RED}locais${NO_COLOR}${BR}."
        fi
    fi
fi

#------Cria o novo repositório-----------
if $REPO_PRIVATE
then
    NEW_REPO_URL=$(gh repo create $REPO_NAME --private --source=. --remote="$REMOTE_NAME" --description="$DESCR")
else
    NEW_REPO_URL=$(gh repo create $REPO_NAME --public --source=. --remote="$REMOTE_NAME" --description="$DESCR")
fi

#------Cria os remotes-----------

git remote rename origin trybe # renomeia o remote da Trybe para 'trybe' (para manter de backup)

#-------Executa script de limpeza com git-filter-repo-------

if bash trybe-filter-repo.sh trybe-security-parameter ; then
    echo -e "${GREEN}Arquivos limpos com sucesso!${NO_COLOR}"
else
    echo -e "${RED}Oooops! Houve algum problema no ${GREEN}'./trybe-filter-repo.sh'${NO_COLOR}"
    echo "A operação de push não foi realizada."
    exit 1
fi

rm -f trybe-filter-repo.sh
cp ${SCRIPTS_BASE}/_NEW_README.md ./README.md

git add README.md
git commit -m "README inicial, em construção 🚧"

if git push -u $REMOTE_NAME $TARGET_BRANCH:main ; then
    echo -e "${GREEN}push feito com sucesso!${NO_COLOR}"
else
    echo -e "${RED}Oooops! Houve algum problema no push ao seu remote pessoal${NO_COLOR}"
    exit 1
fi

#-----Atualiza remotes locais------

git remote remove trybe 
if [[ $REMOTE_NAME == "project-temp-remote-name" ]]
then 
    git remote rename $REMOTE_NAME origin
    echo -e "${GREEN}remote ${NO_COLOR}origin${GREEN} atualizado para o novo repositório."
fi

git branch -m main --force && echo -e "${GREEN}branch ${NO_COLOR}main${GREEN} sincronizada com novo repositório."

echo -e "${GREEN}* * * * * * * * * * * * * * * * * *${NO_COLOR}"
echo -e "Pronto, seu projeto feito na ${GREEN}Trybe${NO_COLOR}"
echo "está no seu respositório pessoal, e "
echo "sincronizado neste diretório local!"
echo 
echo -e "Acesse aqui: ${CYAN}${NEW_REPO_URL}${NO_COLOR}"
echo 
echo -e "Não se esqueça de editar o ${RED}README${NO_COLOR}"
echo "usando nossas recomendações ;)"
echo -e "${GREEN}* * * * * * * * * * * * * * * * * *${NO_COLOR}"