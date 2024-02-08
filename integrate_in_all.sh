#!/bin/bash

PRJCT=all                                     # Указываем проект
etalon_path=$1 #config                                # Указываем путь внутри
file=$2 #docker-compose.yml                                     # Указываем сам файл
push=/$3

etalon_file="/root/ansible/all/blank-docker-all__template/$etalon_path/$file"  # Проверяем путь эталона
destination_root="/root/ansible/$PRJCT"

# Проверяем наличие пути:
if ([ "$file" = '' ] && [ -d $etalon_file ]) || ([ ! "$file" = '' ] && [ -f $etalon_file ]); then
    file="/$file"
    echo
    echo "Работаем с $etalon_file"
    echo "Начинаем через 5 сек"
    sleep 5
else
    echo
    echo "По пути \"$etalon_file\" ничего не найдено!"
    echo 
    exit
fi

# Получаем список всех подпапок
subfolders=($(find "$destination_root" -maxdepth 1 -type d))

# Получаем содержимое эталонного файла
etalon_content=$(<"$etalon_file")

i=0
# Перебираем подпапки и создаем копии файла
for subfolder in "${subfolders[@]}"; do
    if [ "$subfolder" != "$destination_root" ] && [ "$subfolder" != "$destination_root/blank-docker-all__template" ]; then
        target_folder="$subfolder/$etalon_path"
        target_file="$target_folder$file"
        folder=$(echo "$subfolder" | sed 's/.*_\(.*\)/\1/')
        echo $folder

        if [[ "$push" = '/' ]]; then
            if [[ ! "$file" == '/' ]]; then
                # Создаем директории, если их нет
                mkdir -p "$target_folder"

                # Записываем содержимое эталонного файла в целевой файл
                echo "$etalon_content" > "$target_file"
                
                echo "Содержимое файла \"$etalon_file\"   в   ${subfolder##*_}" # $(basename "$subfolder")"
                echo "Скопировано в    \"$target_file\""
            elif [[ "$file" == '/' ]]; then
                # Записываем папку в целевой путь
                cp $etalon_file $(dirname $target_folder) -R

                echo "Содержимое папки \"$etalon_file\"" # $(basename "$subfolder")"
                echo "Скопировано в    \"$target_folder\""
            fi

            # cd $subfolder
            # rm blank-docker-all .git -R
            # if ([[ $folder == "pocketbook-devx" ]] || [[ $folder == "pocketbook-prod" ]]); then
            #     git clone git@gitlab.dreamte.ru:docker/pocketbook/blank-docker-all.git -b $folder
            # else
            #     git clone git@gitlab.dreamte.ru:docker/$folder/blank-docker-all.git -b $folder
            # fi
            # mv blank-docker-all/.git ./.git
            # rm blank-docker-all -R

        elif [[ "$push" = '/push' ]]; then
            # Делаем push
            cd $subfolder
            git config user.name "Никита Зыков"
            git config user.email "nikita-zykov@integlab.ru"
            git add .
            git commit -m "Upd $file [ci skip]"
            git push
            echo "Push сделан в    \"$subfolder\""
        fi
        ((i++))
        echo "№$i/9"
        echo 
    fi
done