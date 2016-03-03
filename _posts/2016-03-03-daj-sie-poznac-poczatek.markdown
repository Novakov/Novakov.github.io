---
layout: post
title: "Daj Się Poznać - Początek"
tags: [dajsiepoznac]
---
No i stało się... Zapisałem się do [Daj się poznać](http://dajsiepoznac.pl) z projektem nad którym spędzam (prawie) zimowe wieczory - **Pather**.

Jego zadania są dwa: poznać technologie, których jeszcze nie miałem okazji używać oraz ułatwić sobie utrzymanie porządku w zmiennej `PATH`. Możliwe, że jestem dziwnym człowiekiem, ale nie lubię dodawać kolejnych i kolejnych ścieżek do systemowego `PATH`, wolę utrzymywać tam ścieżki systemowe i narzędzia globalne (np. `wget`, `git`) a resztę (np. Windows SDK) dodawać do konsoli w której akurat jest coś potrzebne.

O ile ręczne dopisanie czegoś do zmiennej `PATH` w konsoli jest wydaje się być proste, jednak jest z tym związane kilka problemów. Przedewszystkim musimy znać konkretną ścieżkę, którą chcemy dodać, co nie zawsze jest takie proste, na przykład Windows SDK występuje w wielu wersjach, a każda z nich jest w innym folderze. Jeszcze gorzej jeżeli potrzebujemy wielu narzędzi, np. kiedy pracuję z ARMami i potrzebuję GCC, CMake, QEmu i J-Link.

A gdyby tak ścieżki zapisać w pliku a potem załadować jednym prostym poleceniem? A czy niewspaniale by było, gdyby nie trzeba było podawać dokładnych ścieżek a jedynie "wskazówki" jak powinny wyglądać?

W ten sposób narodził się pomysł na projekt **Pather**, którego celem jest zarządzanie zmienną `PATH` zarówno na poziomie systemu jak i pojedynczych procesów przy wykorzystaniu plików w których ścieżki mogą być budowane dynamicznie na podstawie wartości w rejestrze, najwyższej dostępnej wersji i wielu innych.
