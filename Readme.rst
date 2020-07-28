ioquake3 appimage for x86_64
############################

:date: 2020-07-23 14:00
:modified: 2020-07-23 14:00
:tags: ioquake3, quake3
:authors: Pascal Geiser
:summary: Creating a appimage for ioquake3

.. contents::

ioquake3 AppImage
*****************

'ioQuake3 <https://github.com/ioquake/ioq3>'__ is a community effort to continue to maintain and improve
the source code of Quake3 released under the Gnu General Public license by ID software.

'AppImage <https://appimage.org/>'__ is a packaging solution for linux applications, similar to
'Snap <https://snapcraft.io/>'__ or 'Flatpak <https://flatpak.org/>'__

Quake 3 Arena: (C) Copyright (C) 1999-2005 Id Software, Inc.
Do not make illegal copies of the game!

To use it:
 * Read and accept ID software 'eula <https://github.com/13pgeiser/ioquake3-appimage/blob/master/Readme.rst>'__
 * Download the latest tgz archive in the 'releases <https://github.com/13pgeiser/ioquake3-appimage/releases>'__
 * Unpack it.
 * Overwrite the pak0.pk3 file in the *baseq3* folder with the one of your original installation CD.

The first, start the application in a terminal in order to accept the EULA of ID software.

Internals
=========

Docker is used to have a simple, yet consistent build environment. The Dockerfile does the following steps:
 * Package installation: mostly compiler and libraries
 * Clone of ioq3 git repository (https://github.com/ioquake/ioq3)
 * Build of ioq3
 * Download of appimage, pk3 files and demo
 * Packaging in a unified tarball.



