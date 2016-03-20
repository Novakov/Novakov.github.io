---
layout: post
title: "O szukaniu funkcji w procesie"
date: "2016-03-20 21:37:57 +0100"
tags: [dajsiepoznac]
---
W ostanim poście pominąłem temat uzyskania adresu funkcji `LoadLibrary` w przestrzeni adresowej innego procesu.

Zacznijmy od odrobiny informacji teoretycznych. Adres funkcji w pamięci jest sumą dwóch wartości: **adresu bazowego (ładowania) modułu** (pliku wykonywalnego DLL lub EXE) oraz **względnego adresu wirtualnego** (RVA - _Relative Virtual Address_). Pierwsza z tych liczb zależna jest od systemu operacyjnego i określa pod jakim adresem zaczyna się w pamięci biblioteka DLL. Można go uzyskać poprzez standardowe funkcji WinAPI a nawet .NET. Co więcej, niektóre biblioteki systemowe (np. `kernel32.dll`) w każdym procesie znajdują się pod tym samym adresem. Druga potrzeba wartość - RVA - oznacza jak daleko od początku modułu znajduje się funkcja. RVA można znaleźć w nagłówku pliku wykonywalnego.

Naszym zadaniem jest znalezienie adresu funkcji `LoadLibrary` z `kernel32.dll` w pamięci jakiegoś procesu. Ponieważ `kernel32.dll` znajduje się zawsze pod tym samym adresem, również `LoadLibrary` będzie w tym samym miejscu, więc proste wywołanie `GetProcAddress` powinno zwrócić adres prawidłowy w dowolnym procesie. Czemu więc oddzielny post na tak proste zagadnienie?

Zadanie to byłoby proste gdybyśmy mówili o procesach działających w tej architekturze (Pather x86 - program x86 albo Pather x64 - program x64). W przypadku niezgodności sytuacja robi się zdecydowanie bardziej skomplikowana, a wynika ona z faktu, że w systemie Windows (64-bitowym) znajdują się **dwie** wersje `kernel32.dll` - `\Windows\System32\kernel32.dll` oraz `\Windows\SysWOW64\kernel32.dll`. Ta druga wykorzystywana jest w procesach 32-bitowych i nawet jeżeli znalazłby się one pod tym samym adresem ładowania to RVA funkcji `LoadLibrary` będzie inne. Na szczęście aplikacje .NET są niezależne od platformy, więc mogą działać z natywną architekturą, co znacząco ułatawia sprawę, gdyż procesy 32-bitowe w 64-bitowym systemie są "oszukiwane" i z ich punktu widzenia wszystko inne nadal jest 32-bitowe.

Do zdobycia RVA funkcji możemy wykorzystać bibliotekę [PeNet](https://github.com/secana/PeNet), która pozwala na odczytanie nagłówków z plików wykonywalnych - w tym eksportowanych funkcji. Zdobycie ścieżki do pliku napotyka na pewne trudności, gdyż .NET-owa klasa `Process` zwróci `\Windows\system32\kernel32.dll` zarówno dla procesów 64- i 32-bitowych. Na ratunek przychodzi nam **ToolHelp API**, które to zwraca realną scieżkę do modułów procesu. Implementacja potrzebnego (dość prostego) fragmentu znajduje się na [GitHubie](https://github.com/Novakov/Pather/blob/master/src/Pather/ToolHelp.fs). Przy pomocy tego API można także odczytać adres bazowy modułu, dzięki czemu mamy wszystkie fragmenty układanki. Finalny kod funkcji `fundFunction` przedstawia się następująco:

{% gist 3d0ade83c40d82b9725f findFunction.fs %}

Uff... to był długi wstęp (5 postów!), ale dzięki niemu mam pewność, że Pather może (prawie) osiągnąć to czego od niego oczekuję. Drugim dużym zagadenieniem, któremu poświęcę kilka postów będzie parsowanie plików ze ścieżkami, ale to dopiero za jakiś czas. Następne posty będą nieco konkretniejsze.
