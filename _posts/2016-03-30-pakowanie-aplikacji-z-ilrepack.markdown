---
layout: post
title: "Pakowanie aplikacji z ILRepack"
date: "2016-03-30 20:55:08 +0200"
tags: [dajsiepoznac]
---
Aplikacje .NETowe często składają się z wielu plików - jeden plik wykonywalny (.exe) i kilka zestawów w formie bibliotek DLL. Nie jest to złe rozwiązanie, jednak utrudnia trochę rozpowszechanianie programu, gdyż nie można po prostu skopiować jednego pliku. Ponieważ chiałbym mieć łatwo dostępnego Pathera, na przykład jako jeden z plików na GitHub Pages czy do pobrania z GitHuba ropocząłem poszukiwania narzędzi do łączenia wielu plików wykonywalnych .NET jeden. Efektem było znalezienie dwóch narzędzi: [ILMerge](http://research.microsoft.com/en-us/people/mbarnett/ilmerge.aspx) oraz [ILRepack](https://github.com/gluck/il-repack). Za pierwszym z nich przemawia gotowa integracja z FAKE, jednak ostatnia wersja została wydana końcem 2014 roku, a świat .NETowy często się zmienia i nie chciałbym zostać z narzędziem, które nie nadąża za zmianami. Druge - ILRepack - nazywa się alternatywą dla ILMerge'a. Co prawda nie ma gotowej integracji dla FAKE, ale udostępnianie jest w formie bibliteki do użycia we własnym kodzie, a skrypt budujący jest zwyczajnym skryptem F#, więc integracja nie powinna stanowić problemu.

Ostatecznie wybór padł na ILRepack.

## ILRepack w FAKE

Pakowanie aplikacji dodałem jako koleny target. Wykorzystanie ILRepacka sprowadza się do określenia ścieżek do plików wejściowych i wyjściowego. Pierwszy z plików wejściowych będzie tym, do którego będą dokładane kolejne, czyli jego zależności. Cały target jest zaskakująco prosty:

{% gist 7dce7e5952b3371e22eb09f9bb59cd8d pack_target.fs %}

Po zbudowaniu otrzymujemy jeden plik - `Pather.exe` - zawierający w sobie wszystkie zależności.

Gdy jednak spróbujemy zaktualizować zmienną `PATH` jakiegoś procesu staną się złe rzeczy...


## Osadzanie natywnych bibliotek
Pather wykorzystuje dwie natywne biblioteki DLL do modyfikowania zmiennej `PATH` w procesach. Niestety, aby mogłe one być załadowane przez inny proces muszą istnieć jako pliki na dysku, co przeczy idei jednoplikowej aplikacji. Postanowiłem rozwiązać ten problem poprzez osadzenie ich jako zasóbów w `Pather.exe`, a następnie zapisaniu ich na dysku w momencie, kiedy będą potrzebne.

Na początek zmuszenie MSBuilda do umieszczenia binarek jako zasoby poprzez dodanie do `Pather.fsproj`:

{% gist 7dce7e5952b3371e22eb09f9bb59cd8d add_injections.xml %}

Tworzymy nowy target (`_AddInjections`), który wywoła się przed kompilacją (`CallTarget` w `BeforeBuild`). W tym targecie dodajemy do grupy `Injections` dwa elementy określające jakie "wstrzyknięcia" chcemy osadzić jako zasoby. Następnie korzystając z magii MSBuilda definiujemy nowe zasoby (`Resource`) dla plików `.dll` i `.pdb` dla każdej biblioteki DLL. Nie jest to najpiękniejszy kawałek kodu, jednak lepsze to niż ręczne dodawanie plików wyjściowych jednego projektu jako plików źródłowych drugiego.

Mając wszystko co trzeba jako zasoby, możemy przystąpić do zapisania bibliotek na dysku tuż przed wstrzyknięciem ich od innego procesu:

{% gist 7dce7e5952b3371e22eb09f9bb59cd8d unpack.fs %}

Do wyciągnięcia zasobów wykorzystany został `ResourceManager` dający łatwy dostęp do poszczególnych strumieni, a zapisanie ich na dysku jest prostą sprawą. Nazwy zasobów odczytałem przy pomocy ILSpy - jeszcze nigdy nie udało mi się trafić :)

Tak oto Pather stał się jednoplikową, łatwo kopiowalną aplikacją.
