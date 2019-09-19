#/bin/bash
#command as seen in crontab: $sp/transfer.sh $ep

LOCAL_DIR=$1
EXPERIMENT_BASENAME=${LOCAL_DIR##*/}

#! former samba code
# if [ ! -d "/run/user/1001/gvfs/smb-share:server=mnemosyne,share=experiments/$EXPERIMENT_BASENAME" ]; then
#     mkdir -p /run/user/1001/gvfs/smb-share:server=mnemosyne,share=data/CAPS/$( hostname )/scannerData/$EXPERIMENT_BASENAME
# fi

# for f in $LOCAL_DIR/*.tiff; do
#     cp "$f" /run/user/1001/gvfs/smb-share:server=mnemosyne,share=data/CAPS/$(hostname)/scannerData/$EXPERIMENT_BASENAME/
	
#     if [ -f "/run/user/1001/gvfs/smb-share:server=mnemosyne,share=data/CAPS/$(hostname)/scannerData/$EXPERIMENT_BASENAME/${f##*/}" ] ; then
#       rm $f
#       echo "File was copied successfully, removing local copy!"
#     else
#       echo "Mnemosyne not reached, local file not removed!"
#     fi
# done

#! test if "exp" is a directory
# test -d exp && echo yes || echo no
#caps@129.101.130.89:/beta/data/CAPS/experiment/

#rsync will create directories while creating files if necessary
echo "Moving image files to Mnemosyne - folder $EXPERIMENT_BASENAME" 
find $1/*.png -type f -printf "%f\n"
rsync -vha --progress --remove-source-files $1/*.png caps@129.101.130.89:/beta/data/CAPS/experiments/$EXPERIMENT_BASENAME