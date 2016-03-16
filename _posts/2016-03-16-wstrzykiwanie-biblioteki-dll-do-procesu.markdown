---
layout: post
title: "Wstrzykiwanie biblioteki DLL do procesu"
date: "2016-03-16 08:35:10 +0100"
tags: [dajsiepoznac]
---
Poprzedni post skończył sie napisaniem (nieprzechodzących) testów. Teraz nadszedł czas na implementację mechanizmu wstrzykiwania biblioteki DLL do innego procesu.

Na początek stwórzmy bibliotekę, która będzie wstrzykiwana w docelowy proces. Niestety nie możemy jej napisać w F# ponieważ musi być ona natywna (i zgodna z architekturą docelowego procesu), tak więc wykorzystamy C++. Po załadowaniu do procesu wywołana zostanie funkcja `DllMain`:

{% gist 5133d814a3665a809ca5 DllMain.cpp %}

Zwrócenie wartości `FALSE` powoduje natychmiastowe wyładowanie biblioteki z pamięci. Dzięki temu nie będzie zaśmiecać docelowego procesu. Komunikacja z Patherem odbywać będzie się przy pomocy **named pipe**, a cała pętla obsługi znajduje się w funkcji `injection`:

{% gist 5133d814a3665a809ca5 injection.cpp %}

Nazwa potoku budowana jest według wzoru: `\\.\pipe\pather\<id-procesu>`, a na na protokół składają sie trzy operacje: echo (kod 45), ustawianie (01) i odczytywanie (02) zmiennej środowiskowej.  Na razie zostawy ich implementację i przyjrzyjmy się jak to wygląda stronie Pathera, która jest zdecydowanie bardziej złożona.

Na początek trzeba zaimportować kilka funkcji WinApi:
{% gist 5133d814a3665a809ca5 DllImports.fs %}

Wstrzykiwanie biblioteki DLL do jakiegoś procesu opiera się na utworzeniu w nim wątku (z pomocą `CreateRemoteThread`) z funkcją `LoadLibrary` jako entrypointem i ścieżką do biblioteki jako parametrem w postaci wskaźnika na łańcuch znaków zakończony znakiem 0. Wymaga to uprzedniego umieszczenia go w pamięci procesu co umożliwia para `VirtualAllocEx` i `WriteProcessMemory`. Całość rozbudowana o wybranie odpowiedniej wersji biblioteki DLL (x86 albo x64) przedstawia się następująco:
{% gist 5133d814a3665a809ca5 inject.fs %}

Funkcja `findFunction` pozwala na określenie adresu zadanej funkcji w przestrzeni adresowej docelowego procesu i będzie tematem następnego postu.

Mając mechanizm wstrzykiwania możemy obudować go w obsługę named-pipe:
{% gist 5133d814a3665a809ca5 openChannel.fs %}

Mając podstawową obsługę komunikacji z obu stron możemy zaimplementować trzy operacje:

ze strony Pathera:
{% gist 5133d814a3665a809ca5 funcs.fs %}

oraz biblioteki DLL:
{% gist 5133d814a3665a809ca5 funcs.cpp %}

Wyjaśnienia wymagają funkcje C++ `readString`, `readStringLength`, `writeString` oraz `writeStringLength` - są to funkcje implementujące ten sam sposób kodowania łańcuchów znaków co `BinaryReader` i `BinaryWriter`. Ich implementacja jest bliźniaczo podobna do ich odpowiedników w .NET ([BinaryReader.ReadString](http://referencesource.microsoft.com/#mscorlib/system/io/binaryreader.cs,2331740401e9cb96), [BinaryWriter.WriteString](http://referencesource.microsoft.com/#mscorlib/system/runtime/serialization/formatters/binary/binaryformatterwriter.cs,7947abdf37ec549d)).

Świadomie nie skupiałem się na problemach związanych z aplikacjami 32-bitowymi na 64-bitowym systemie - jedynie funkcja `injectLibrary` wybiera odpowiednią bibliotekę na podstawie architektury docelowego procesu. Problemy związane z WoW64 zostaną opisane w następnym poście.
