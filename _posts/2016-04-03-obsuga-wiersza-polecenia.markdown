---
layout: post
title: "Obsługa wiersza polecenia"
date: "2016-04-03 21:54:23 +0200"
tags: [dajsiepoznac]
---
Obsługa wiersza polecenia, a własciwie argumentów przekazywanych w ten sposób, to temat rzeka. Istnieje niezliczona liczba bibliotek i konwencji z których każda ma swoje wady i zalety. Pather, jako narzędzie wiersza polecenia, też musi sobie z tym poradzić. Zacząłem od określenia jak chciałbym, aby wyglądały polecenia:

* `pather load jekyll.paths`
* `pather config-sys --part system  -f system.paths`

Nie będę ukrywał, że wzorowałem się na narzędziach takich jak Git czy Bundler, gdzie pierwszym argumentem jest polecenie po którym następują kolejne wartości w formie argumentów pozycjnych lub nazwanych. Te ostatnie występują w formie: `-n wartość` lub `--name wartość`.

Do implementacji mechanizmu postanowiłem wykorzystać bibliotekę [CommandLineParser](https://github.com/gsscoder/commandline). W środowisku F# popularna jest biblioteka [Argu](https://github.com/fsprojects/Argu), jednak nie wspiera ona funkcjonalności poleceń jako pierwszego argumentu. Całość postarałem napisać w taki sposób, aby nowe polecenia pojawiały się automatycznie po dodaniu odpowiedniego pliku źródłowego. Stanowi to wspaniałą okazję do ze sposobem w jaki elementy F# odwzorowywane są w struktury CLR.

Implementacja pojedynczego polecenia umieszczona jest w pliku w folderze `Commands`:

{% gist a60a503481d281ab75da2fd41b05e110 command.fs %}

Argumenty opisuje rekord `Args` a za wykonanie odpowiada funkcja `execute`. Teraz wystarczy tylko zebrać wszystkie rekordy argumentów z całej aplikacji, sparsować wiersz polecenia i wykonać odpowiednią funkcję `execute`. Krótka zabawa z ILSpy pokazuje, że moduły są klasami oznaczonymi atrybutem `CompilationMappingAttribute` z ustawioną właściwością `SourceConstructFlags` na `Module`. W tej klasie musimy znaleźć klasę `Args` z atrybutem `VerbAttribute`:

{% gist a60a503481d281ab75da2fd41b05e110 find_args.fs %}

Po dostarczeniu tablicy z typami argumentów CommandLineParser wykonuje swoją część roboty i dostajemy obiekt odpowiedniego typu. Teraz musimy znaleźć tylko odpowiednią funkcję `execute`, co jest dość proste:

{% gist a60a503481d281ab75da2fd41b05e110 execute.fs %}

Funkcja execute będzie składową typu, do którego należy typ argumentów.

Biblioteka CommandLineParser dobrze się sprawia, a odrobina refleksji pozwala elegancko rozdzielić implementację poszczególnych poleceń.
