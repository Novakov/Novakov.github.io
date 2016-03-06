---
layout: post
title: "Gdzie siedzą zmienne środowiskowe?"
date: "2016-03-06 21:54:06 +0100"
tags: [dajsiepoznac]
---
Głównym zadaniem Pathera jest zmienianie wartości zmiennych środowiskowych, a żeby to osiągnąć trzeba dowiedzieć się, gdzie są one przechowywane. W Windowsie znajdują się trzy zestawy zmiennych środowiskowych:

 1. Domyślne zmienne systemu
 1. Domyślne zmienne użytkownika
 1. Zmienne procesu

## Domyślne zmienne

Dwa pierwsze zestawy wykorzystywane są przez powłokę (`explorer.exe`) podczas tworzenia procesu i są łatwo dostępne poprzez ustawienia systemowe:

![Domyślne zmienne środowiskowe](/images/posts/system_env_variables.png)

Zmienne systemowe mogą być zmieniane jedynie przez administratora i są wspólne dla wszystkich korzystających z systemu. Zmienne użytkownika pozwalają na nadpisanie (lub dopisanie w przypadku zmiennej `PATH`) ustawień systemowych przez poszczególnych użytkowników.

Informacji o tym gdzie znaleźć (i zmienić) domyślne wartości zmiennych dostacza [TechNet](https://technet.microsoft.com/en-us/library/ee156595.aspx): zmienne użytkownika przechowywane są w `HKCU\Environment`, a systemowe w `HKLM\System\CurrentControlSet\Control\Session Manager\Environment`. Na szczęście zmiana w rejestrze jest wystarczająca, aby Explorer wykorzystał nowe wartości.

## Zmienne procesu
W przypadku procesów sprawa dostępu do zmiennych środowiskowych nie jest taka oczywista. Sam proces ma możliwość ich ustawiania (funkcje WinAPI: [SetEnvironmentVariable](https://msdn.microsoft.com/pl-pl/library/windows/desktop/ms686206.aspx), [GetEnvironmentVariable](https://msdn.microsoft.com/pl-pl/library/windows/desktop/ms683188.aspx)) jednak MSDN nic nie wspomina o ustawianiu ich przez inny proces, co oznacza, że trzeba ich poszukać.

Poszukiwania zaczniemy od uruchomienia `cmd.exe` i podpięcia się do niego w WinDbg. Pierwszym podejrzanym w którym mogą siedzieć zmienne procesu jest `PEB` (Process Environment Block). Szybkie sprawdzenie w WinDbg:

```
> !peb
PEB at 0000000e8dd78000
    InheritedAddressSpace:    No
    ReadImageFileExecOptions: No
    BeingDebugged:            Yes
    ImageBaseAddress:         00007ff7df810000
    Ldr                       00007ffc55905200
    Ldr.Initialized:          Yes
    Ldr.InInitializationOrderModuleList: 000001624c582c80 . 000001624c5860c0
    Ldr.InLoadOrderModuleList:           000001624c582de0 . 000001624c5860a0
    Ldr.InMemoryOrderModuleList:         000001624c582df0 . 000001624c5860b0
                    Base TimeStamp                     Module
            7ff7df810000 5632d733 Oct 30 03:34:27 2015 C:\WINDOWS\SYSTEM32\cmd.exe
            7ffc557c0000 56cbf9dd Feb 23 07:19:09 2016 C:\WINDOWS\SYSTEM32\ntdll.dll
            7ffc55710000 5632d5aa Oct 30 03:27:54 2015 C:\WINDOWS\system32\KERNEL32.DLL
            7ffc51e70000 56a8489c Jan 27 05:33:32 2016 C:\WINDOWS\system32\KERNELBASE.dll
            7ffc53610000 5632d79e Oct 30 03:36:14 2015 C:\WINDOWS\system32\msvcrt.dll
                7e110000 56d69d20 Mar 02 08:58:24 2016 D:\Tools\ConEmu\ConEmu\ConEmuHk64.dll
            7ffc55060000 565423d2 Nov 24 09:46:10 2015 C:\WINDOWS\system32\USER32.dll
            7ffc53420000 568b2035 Jan 05 02:45:25 2016 C:\WINDOWS\system32\GDI32.dll
            7ffc531b0000 5632d48d Oct 30 03:23:09 2015 C:\WINDOWS\system32\IMM32.DLL
            7ffc4b3d0000 5632d813 Oct 30 03:38:11 2015 C:\WINDOWS\SYSTEM32\winbrand.dll
    SubSystemData:     0000000000000000
    ProcessHeap:       000001624c580000
    ProcessParameters: 000001624c582490
    CurrentDirectory:  'C:\Users\Novakov\'
    WindowTitle:  'ConEmu'
    ImageFile:    'C:\WINDOWS\SYSTEM32\cmd.exe'
    CommandLine:  '"C:\WINDOWS\SYSTEM32\cmd.exe"'
    DllPath:      '< Name not readable >'
    Environment:  000001624c58b920
        =::=::\
        =C:=C:\Users\Novakov
        ALLUSERSPROFILE=C:\ProgramData
        ANSICON=170x9999 (170x41)
        ANSICON_DEF=7
        APPDATA=C:\Users\Novakov\AppData\Roaming
        CARBON_MEM_DISABLE=1
        ChocolateyPath=C:\Chocolatey
        CodeContractsInstallDir=C:\Program Files (x86)\Microsoft\Contracts\
        CommonProgramFiles=C:\Program Files\Common Files
        CommonProgramFiles(x86)=C:\Program Files (x86)\Common Files
        CommonProgramW6432=C:\Program Files\Common Files
        <dużo innych zmiennych>
        Path=D:\Tools\ConEmu\ConEmu\Scripts<dużo innych ścieżek>
        <jeszcze więcej zmiennych>
```

Bingo! PEB w jakiś sposób wskazuje na blok zmiennych środowiskowych, pytanie brzmi: jak się dostać konkretnego adresu w pamięci? To kolejna sytuacja w której MSDN nam nie pomoże, ponieważ większa część struktury PEB jest nieudokumentowana, jednak z tego co wiadomo wraz z kolejnymi wersjami systemu jest jedynie rozszerzana o następne pola. Wspaniałym przewodnikiem po wnętrznościach Windowsa jest [http://terminus.rewolf.pl/terminus/](http://terminus.rewolf.pl/terminus/). Dowiadujemy się, że ścieżka prowadząca do zmiennych środowiskowych to `PEB->ProcessParameters->Environment`. Oglądając pamieć pod tym adresem okaże się, że mamy doczynienia z listą stringów zakończonych znakiem 0, a dodatkowo cała lista kończy się kolejnym znakiem 0. Sprawdźmy zatem czy modyfikując pamięć wskazywaną przez to pole zmienimy wartość zmiennej `PATH` procesu. Chwila kombinowania z oknem Memory i zmieniamy `D:\Tools` na `Y:\Tools`. Sprawdźmy poleceniem `!peb`:

```
> !peb
PEB at 0000000e8dd78000
    <to samo co wcześniej>
        Path=Y:\Tools\ConEmu\ConEmu\Scripts;...
```

Sukces! Znaleźliśmy sposób na zmianę zmiennej bez korzystania z funkcji WinAPI, a operowanie na pamięci innego procesu jest stosunkowo prostą (i dla odmiany - udokumentowaną) czynnością otwierając drogę do implementacji podstawowej funkcji Pathera.

Dla pewności wywołajmy jeszcze polecenie `set PATH` w `cmd`:
```
C:\>set PATH
Path=D:\Tools\ConEmu\ConEmu\Scripts;...
```

Ups...

_Dwa dni debugowania WinAPI później..._

Modyfikacja pamięci wskazanej przez PEB nie wystarczy. Funkcje systemowe oprócz budowania nowego bloku przechowują go także w buforze (`ntdll!RtlpQueryEnvironmentCache`). Po głębszym zastanowieniu ma to nawet sens, gdyż zmienne środowiskowe mogą wykorzystywać inne, a odczytując wartość którejś z nich chcielibyśmy uzyskać wartość ostateczną. Wyznaczanie jej za każdym razem byłoby niepotrzebym kosztem zwłaszcza, że jedyny (oficjalny) sposób na zmianę zmiennej to `SetEnvironmentVariable`.

Sprawa komplikuje się jeszcze bardziej jeśli weźmiemy pod uwagę aplikacje 32-bitowe uruchomione w 64-bitowym systemie (WoW64). Eksperymenty pokazały, że blok zmiennych środowiskowych wskazyny przez PEB nie jest tym z którego korzystają funkcje systemowe. Proces WoW64 taki ma zdublowane niektóre struktury systemowe, np. PEB i o ile możliwe jest uzyskanie adresu 64-bitowego PEBa, to jego 32-bitowy odpowiednik (w którym powinien być wskaźnik na rzeczywiste zmienne środowiskowe) nie jest taki łatwy do znalezienia, zwłaszcza, że w Windows 10 zmienił swoje położenie względem PEB64 (było to 4MB różnicy).

Problemy te wskazują, że pierwotnie wybrana droga okazała się ślepa. Oczywiście nie oznacza to, że nie da się osiągnąć tego samego celu innymi.

*Ciąg dalszy nastąpi...*
