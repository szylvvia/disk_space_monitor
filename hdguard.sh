#!/bin/bash

#----------------------------------------------KRÓTKI-OPIS---------------------------------------------
#Autor:Sylwia Krzysztoń
#Skrypt monitoruje co 60 sekund(od zakoczenia dzialania) zajetosc dysku. W przypadku napotkania 
#bledów(nieprawidlowe podanie danych) jest zatrzymywany i nalezy wlaczyc go od nowa.
#Po sprawdzeniu dysku, znajduje pliki do usuniecia i wyswietla ponumerowane uzytwkonikowi(malejaco)
#Wowczas uzytwkownik ma mozliwosc wybrania usuwania wybranych, wszytkich badz dalsze przejscie
#do monitorowania. Przy braku aktywnosci przez 60 sekund przy wyborze, skrypt uruchomi sie ponownie za 60 sekund.
#W przypadku usuwania tworzony jest plik z lista usunietych plikow
#pod nazwa hdguard_data_godzina.deleted.
#Skrypt korzysta z jednego paramteru (musi byc jeden) wprowadzanego przy wywolywaniu skryptu.
#Musi byc liczbą oraz miesic sie w zakresie (30;99)


#--------------------------------------------FUNKCJE-------------------------------------------

#zmienna przechowujaca sciezke do pliku/niezbedna do ponownego uruchomienia
path=`echo $0`;


#funkcja zwraca informacje na temat stanu zajętosci dysku
info(){
    #zmienna przechowujaca nazwę partycji
    partiition_name=$( df /home/$USER | awk '{print $1}' | sed -n 2p );
    #zmienaa przechowujaca rozmiar partycji
    partition_size=$(df /home/$USER | awk '{print $2}' | sed -n 2p);
    #zmienna przechowujaca ilosc wolnego miejsca
    partition_free_space=$(df /home/$USER | awk '{print $4}' | sed -n 2p )
    #zmienna przechpowujaca procent zajętosci dysku
    partition_p_use=$(df /home/$USER | awk '{print $5}' | sed -n 2p | cut -c1-2)
    #zmienna przechowujaca zajetosc dysku
    partition_use=$(df /home/$USER | awk '{print $3}'|sed -n 2p)
    

    #wyswietlenie wybramych danych
    echo -e "\n***************************************************";
    echo -e "WYNIKI MONITOROWANIA PARTYCJI: $name "
    echo -e "-> Nazwa dysku: $partiition_name"
    echo -e "-> Rozmiar partycji: $partition_size"
    echo -e "-> Wolne miejsce $partition_free_space"
    echo -e "***************************************************\n";

    #zmienna pomocnicza do pzrechowywyania rozmiaru plikow do susniacia, zsumowanych
    file=0;
    #zmienna przechowujaca wzorzec do sprawdzania czy wprowadzana zmienna jest liczba
    re='^[0-9]+$'
};


#funkcja sprawdzajaca czy zajetosc partycji jest wieksza niz spodziewa sie tego uzytwkonik
#umozliwa wybor dalszych dzialan
check(){
    if [ $partition_p_use -gt $g ];
    then
        echo "Wartosc graniczna $g% zuzycia pamieci na dysku zostala przekroczona"
        echo -e "Czy chcesz rozpoczac wybor wybor plikow i czysczenie dysku?\n"
        echo "Nacisnij 1 jesli TAK lub 2 jestli NIE"
        echo "Jesli wcisniesz 9 rozpocznie się proces USUWANIE WSZYTSKICH ZBEDNYCH plikow"
        echo "Kazda inna liczba zakonczy skrypt"
        echo "Masz 60 sekund na podjecie decyzji inaczej nastapi ponowne monitorowanie"
        #zczytanie wyboru uzytkownika co do dalnych krokow
        read -n 1 -t 60 -p "Twoj wybor:" r
        #instrukcja warunkowa, ktora przy pustej zmiennej-braku katywnosci w ciagu 60 sekund wujdzie z petli/funkcji
        if [ -z "${r}" ];
        then
           echo -e "Brak aktywności\n";
        #instrukcja warunkowa, sprawdzajaca porawnosc wprowadzanych danych(ma byc liczba)
        elif ! [[ $r =~ $re ]] ; 
        then
            echo "Nie podlaes liczby. Wlacz skrypt ponownie i wprowadz poparwne dane" >&2; exit 1
        fi

    fi
}

#funkcja wyszukaca pliki z katalogu domowego uzytkownika, ktrre mozna usunac,posortowanie ich oraz zapis do pliku tmp
#w dwoch kolumnach tj. rozmiar, nazwa/sciezka dostepu do pliku
find_files()
{
    find /home/$USER -type f -not -user "root" -writable -not -name ".*" -not -name "*.config$" -printf "\t%s\t%h/%f\n" | sort -nr > tmp; 
}

#funkcja umozliwiajaca wbor plikow do usuniecia, po wczesniejszym wyswietleniu ich uzytkonikowi
choose(){
    echo -e "LISTA PLIKOW MOZLIWYCH DO USUNIECIA \n";
    #wyswitlenie ponumerowanej listy plikow
    nl tmp;
    #zliczenie wierszy pliku, co odpowiada liczbie wyszukanych plikow
    len=$(wc -l tmp |awk '{print $1}')
    #wyswietlenie informacji i komuinikatow
    echo -e "Znalezniono: $len plikow\n";
    echo -e "Trzeba zwolnic: "$need" pamieci\n"
    echo "Wybierz numery plikow do usuniecia i kliknij ENTER";
    echo -e "Do odzielenia licz nie uzywaj spacji";
    echo -e "Jesli klikniesz 0 zakonczysz wybieranie plikow\n";
    #petla umozliwiajaca dodawanie kolejnych plikow do usuniecia
    while [ $r -ne 0 ];
    do
        #zczytanie numeru pliku o okreslonej liczbie porzadkowej
        read -p "Podaj numer: " t
        echo -e "\n"
        #sprawdzenie porawnosci wprowadzonych danych
        if ! [[ $t =~ $re ]] ; 
        then
            echo "Nie podlaes liczby lub podales je po spacji. Wlacz skrypt ponownie i wprowadz poparwne dane" >&2; exit 1
        else 
            #jesli zostanie wybrane 0 wyjscie z petli i zakonczenie wybierania plikow, o ile rozmiar wybranych plikow 
            #pozwoli na zejscie ponizej wartosci graniczej, nizebedna petla jest potem,w programie glownym
            if [ $t -eq 0 ];then break;
            #sprawdzanie czy wynrana liczba/numer pliku nie wychodzi poza zakres
            elif [ $t -gt $len ];
            then
                #w przypadku wyjscia z ekryptu, zostanie usuniety plik przechowujacy dane do usuniecia, aby w poznijeszych  wywolaniach nie było "śmieci" 
                if [ -e check.txt ]; then rm -r check.txt; fi;  
                echo "Za duza liczba!">&2; exit 1
            else
                #wyluskannie inofmracji o pliku o okrelsonej liczbie porzadkowej i zapisanie do nowego pliku pomocniczego
                sed -n `echo $t`p tmp>> check.txt
                #wysluskanie rozmiaru pliku
                fileT=$(sed -n `echo $t`p tmp | awk '{print $1}');
                if ! [[ $fileT =~ $re ]] ; 
                then
                    if [ -e check.txt ]; then rm -r check.txt; fi;  
                    echo "Wystapil blad. Poza zakresem. Przepraszamy. Uruchom skrypt ponownie" >&2; exit 1
                fi  
                echo $fileT
                #sumowanie kolejnych rozmiarow plikow 
                file=$(($file+$fileT));
                fileD=$(($need-$file));
                echo "Potzeba jescze plikow o rozmiarze co najmniej: "$fileD
                #usniecie okreslonego pliku z listy ywboru
                sed -i `echo $t`d tmp;
                #ponowne wyswietlenie listy plikow, ktore mozna usunac
                echo -e "LISTA PLIKOW MOZLIWYCH DO USUNIECIA \n";
                nl tmp;
                echo -e "LISTA PLIKOW DO USUNIECIA \n";
                nl check.txt
            fi;
        fi;
    done;
}

#funkcja sprawdzajaca ile pamieci tzrevba zwolnic aby sporstac oczekiwaniom uzytkonika (niezbedne obliczenia)
check_size()
{   
    disk1=$(($partition_size*$g));
    disk=$(($disk1/100))
    need=$(($disk-$partition_use));
    echo -e "Minimalnie tyle pamieci nalezy zwolnic: $need\n"  
}

#funkacja usuwajaca wybrane pliki
delete_files()
{
    #wyliczenie ilsoci plikow do usuniecia
    how=$( wc -l check.txt | awk '{printf $1}' )
    echo -e "Zostanie usuniete: "$how "plik/plikow\n"
    #petla usuwajaca pliki, i wyswietlajaca ich nazwy kolejno 
    for (( i=1; i<=$how; i++ ));
    do
        #tworzenie nazwy pliku, ktora bierze pod uwage znak spacji w pliku
        fd=$(sed -n `echo $i`p check.txt | awk '{out=$2; for(i=3;i<=NF;i++){out=out" "$i}; print out}') 
        echo "Usuwam plik: $fd"
        #usuniecie pliku
        rm -r "`echo $fd`";
    done;
    echo "Zakonczono usuwnie plikow"
}

#funkcja usuwajaca wszytskie znaleznione pliki
delete_all_files()
{
    #policzenie plikow do usuniecia
    how=$( wc -l tmp | awk '{printf $1}' )
    #wyswitlenie ile plikow bedzie usuwane
    echo "Zostanie usniete: "$how" plikow";
    #petla usuwajaca po kolei wszytskie pliki i wyswietlajaca iuch nazwy
    for (( i=1; i<=$how; i++ ));
    do
        #tworzenie nazwy pliku, ktora bierze pod uwage znak spacji w pliku
        fd=$(sed -n `echo $i`p tmp | awk '{out=$2; for(i=3;i<=NF;i++){out=out" "$i}; print out}') 
        echo "Usuwam plik: $fd"
        #usuniecie pliku
        rm -r "`echo $fd`";
    done;
    echo "Zakonczono usuwnie plikow"
}

#funkcja do tzw. "pulapki", w przypadku gyd istneieje pliktmp i check.txt (pliki tymczasowe, na potzreby skryptu)
#zostana one usuniete
finish() 
{
       if [ -f tmp ];
       then
            echo -e "\nUsuwam plik tymczasowy: tmp"
            rm -r tmp
        fi;
        if [ -f check.txt ];
      then
            echo "Usuwam plik tymczasowy check.txt"
            rm -r check.txt
      fi;
      echo -e "\nWyjscie z programu.\nDo widzenia!\n"
      exit 0;
}

#w przypadku gdy uzytkownik nieoczekiwanie naciesnie CTRL+C i zakonczy wykonywanie skryptu wowczas, wywola sie funkcja finish i usunie pliki tymczasowe
#aby przy kolejnym wywolaniu nie bylo tzw smieci
trap finish SIGINT


#--------------------------------------------PROGRAM GLOWNY-------------------------------------------

#zmienna przechowujaca wartosc graniczna podana przy wywolaniu skryptu
g=$1

#sprawdzanie poprawnosci wprowadzanych danych
echo $g
    #sprawdzanie czy jest liczba
    if ! [[ "$g" =~ ^[0-9]+$ ]]
    then
        echo "Nie podano liczby"
        exit 1
    #instrukcja warunkowa sprawdzajaca czy zostala podana dokladnie jedna wartosc
    elif [ "$#" -ne 1 ];
    then
        echo "Podano niewlasciwa liczbe argumentow" ; 
        exit 1
    fi;

#petla nieskonczona pozwlajaca na ciagle moinitorowanie dysku, 
#ale tylko w przypadku gdy nie zostana podane zle dane, 
#wowczas petla zostaje zakonczona i uzytkownik musi uruchomic skrypt ponownie
for inf in *
do
    clear;
    #sprawdzenie czy podana wartosc jest z okreslonego zakresu(ustawione przeze mnie domyslnie)
    if [ $1 -ge 30 -a $1 -le 99 ]
    then
        echo -e "\n1.Wyswietlanie informacji o partycji\n"
        #funkcja wyswietlajaca informacje o partycji
        info;
        echo -e "\n2.Obliczam ile miejsca tzreba zwolnic\n"
        #obliczenie ile pamięci trzeba zwolnić
        check_size;
        echo -e "\n3.Lista znleaznionych plikow do usuniecia:\n"
        #funkcja wyszukujaca pliki do usuniecia
        find_files; 
        #wyswietlenie listy plikow wyszukanych(ponumerowana lista)
        nl tmp;
        echo -e "\n4.Czekam na twoj wybor co do dalszycn dzialan\n"
        #pobranie "wyboru" uzytkownika, co do dalych dzialan
        check;
        #w przypadku braku aktywnosci/pusta zmienna wyboru, skryot po 60 sekundach zostanie uruchomiony ponownie
        if [ -z "${r}" ];
        then
            echo -e "Brak aktywnosci. Za 60 sekund monitorowanie zostanie wznowione "
            sleep 60
            source `echo $path`
        fi;
        #instrukcja warunkowa sprawdzajaca czy podana wartosc nie jest mniejsza niz faktyczna
        #zajetosc dysku, poniewaz wowczas nie ma czego czyscic
        if [ $g -lt $partition_p_use ];
            then
            if [ $r -eq 1 ]; 
            then
                echo -e "\n5.Wybieranie plikow\n"
                choose;
                #petla wymuszajaca podawania danych az wartosc pamieci, ktora tzreba zwolnic bedzie wystaczajaca
                while [ $file -lt $need ];
                do
                    echo "Rozmiar wybranych plikow nie spowoduje przejscia do wartosci granicznej, wybieraj dalej"
                    #ponowne wywolanie funkcji w przypadku, za malej ilosci miejsca do zwolenenia, analoicznie do wczesniejeszego komentarza
                    choose;
                done;
                #przejscie do usuwania plikow, ale tlko gdy uzytkownik cos wybral do usuniecia
                echo -e "\n6.Usuwanie plikow\n"
                if [ -s check.txt ];
                then
                    #przygotowanie czlonu nazwy do pliku wynikowego
                    dn=$(date "+%Y-%m-%d_%T")
                    #utworzenie listy plikow usunietych
                    cp check.txt hdguard_`echo $dn`.deleted
                    #wywolanie funkcji powodujacej usuniecie plikow
                    delete_files;
                    #usuniecie listy z plikami do susuniecia
                    rm -r check.txt;
                else
                    echo "Nie ma czego usuwac. Pliki nie zostaly wybrane"
                fi;
            #usuniecie wszytskich plikow
            elif [ $r -eq 9 ]
            then
                #przygotowanie czlonu nazwy do pliku wynikowego
                dn=$(date "+%Y-%m-%d_%T")
                #utworzenie listy plikow usunietych
                cp tmp hdguard_`echo $dn`.deleted
                echo -e "\n7.Usuwanie wszytkich plikow\n"
                #usuniecie plikow oraz stareego plikow z lista
                delete_all_files
                rm -r tmp;
            else  echo -e "\nProces usuwanie plikow nie zostal zaakceptowany przez uzytkownika\n\nPowrot do minitorowania dysku za 60 sekund"
            fi;
        else 
            echo -e "\nWartosc graniczna jest wieksza od wartosci zajetosci dysku. Wszytsko jest w porzadku. Nie tzreba sprzatac\nPowrot do minitorowania dysku za 60 sekund"
        fi;
    else
        echo -e "\nBledne dane\nZa mala wartosc"
        exit 1;
    fi;
    echo -e "\nDysk zostanie ponownie sprawdzony za 60 sekund\nDo zobaczenia!\n"

    #wywolanie komendy pozwala na ponowne przejscie przez petle for w celu ciaglego monitorowania dysku co minute
    #ale tylko w przypadku gdy caly proces przebiegl pomyslnie i nie zostaly podane zle dane
    
    sleep 60;

done;



