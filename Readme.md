# Deploiement Geopoppy sur android:  Lizmap, Postgresql et Qgis server

* Vérifier que ton smartphone est en 64 bits : app [droidinfo](https://play.google.com/store/apps/details?id=com.inkwired.droidinfo&hl=fr)

* [Téléchager ce dépot sur le smartphone](https://github.com/jancelin/geopoppy_android/archive/master.zip) et décompresser les dossiers dans un nouveau dossier geopoppy créé dans Android/data/tech.ula/files/storage.

![adapter3](https://github.com/jancelin/geopoppy_android/blob/master/image/IMG_20190613_222233_507.jpg)

* [télécharger sur le smartphone l'image Userland](https://github.com/jancelin/geopoppy_android/releases/download/geopoppy_android_0.2/geopoppy0_2-debian-rootfs.tar.gz)

* installer app [connectBot](https://play.google.com/store/apps/details?id=org.connectbot)

* installer app [Userland](https://play.google.com/store/apps/details?id=tech.ula) et ouvrir

* aller dans l'onglet systèmes de fichiers et compléter (adapter en fonction de la version téléchargée)

![adapter1](https://github.com/jancelin/geopoppy_android/blob/master/image/Screenshot_20190522-132931.png)

* aller dans sessions et compléter

![adapter2](https://github.com/jancelin/geopoppy_android/blob/master/image/Screenshot_20190522-132959.png)

* cliquer sur la session créée

* userland propose d'ouvrir connectbot, valider

* saisir le mot de passe session: 12345678

* Lancer le script de démarrage :

```sh /storage/internal/geopoppy/conf/start.sh```

* attendre que  postgresql, nginx, PHP, et qgis server soit démarrés ( qgis reste en log debug), 

### Ne Pas fermer la session !

* ouvrir firefox et adresse:

http://localhost:2080/lizmap
