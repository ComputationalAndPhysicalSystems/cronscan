#rsync -zha 200328_shadow-pink-clock-3-9_1/ caps@129.101.130.88:~/lab/segment/200328_shadow-pink-clock-3-9_1/
rsync -zha -v --stats --progress $1/ caps@129.101.130.88:~/lab/segment/$1/
