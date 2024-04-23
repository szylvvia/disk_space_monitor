<h1> HDGUARD - disk space monitor </h1>
<p><i>Shell script</i></p>

<h2>Opis działania</h2>
<p align="justify">
Skrypt ma za zadanie monitorować co 60 sekund dysk/określoną partycje. W przypadku nie podania poprawnych
wartości przy wywołaniu skrypt ulega zamknięciu. Wartość musi być liczba określoną na przedziale otwartym (30;99).
W przypadku gdy wartość jest za mała w skrypt kończy działanie, Ponadto przy wywołaniu skrypt przyjmuje tylko
jedną wartość, inaczej również ulega zamknięciu. Wartość graniczna pobierana jest przy wywoływaniu skryptu.
Zadeklarowana zostaje zmienna path która przechowuje ścieżkę do pliku, zmienna file do sumowania rozmiarów plików
wybranych, zmienna re jako wzorzec do sprawdzania poprawności danych, zmienna g (czyli to co zostaje podane przy
wywołaniu skryptu) do przechowywania wartości granicznej, powyżej której użytkownik chce by partycja była
czyszczona.
Zostaje zadeklarowana „pułapka”, która w przypadku ręcznego zakończenia działania skryptu, usuwa pliki tymczasowe
służące do przechowywania danych podczas działania skryptu (o ile one istnieje), a następnie zgodnie z wolą
użytkownika kończy działanie skryptu.
Na początku sprawdzana jest poprawność danych, które są wprowadzane w momencie wywołania skryptu. Wartość
musi być liczbą, nie można podać więcej niż jednej wartości. Gdy dane nie są poprawne skrypt kończy działanie.
Jeśli dane wejściowe są poprawne skrypt przechodzi do dalszych kroków. Pętla nieskończona ma za zadanie powtarzać
działania aż do ręcznego zatrzymania lub w przypadku braku poprawności wprowadzanych danych. Zmienna graniczna
g zostaje sprawdzona czy zawiera się w określonym przedziale. Następnie jeśli spełnia te warunki, zostają zbierane
informacje o partycji. Wybrane informacje zostają wyświetlone użytkownikowi, reszta pozostaje do niezbędnych
działań skryptu. Następnym krokiem jest obliczenie ile pamięci trzeba zwolnić, aby zejść poniżej wartości granicznej
zadeklarowanej przez użytkownika, zostaje wyświetlona ta wartość. Skrypt wyszukuje pliki, które można usunąć i
zapisuje do pliku tmp. Następnie w liście ponumerowanej wyświetla je użytkownikowi. Następnie skrypt pobiera dane
odnośnie wykonywania dalszych zadań. Przy nieaktywności użytkownika przez 60 sekund(nie podanie danych), skrypt
zostaje ponownie uruchomiony za 60 sekund. Jeśli nie zostały podane cyfry, skrypt kończy działanie. Podanie 1
przechodzi do wybierania listy usuwanych plików, 9 oznacza przejście do usuwania wszystkich plików
zaproponowanych wcześniej, natomiast 2 i każda inna umożliwia przejście do ponownego monitorowania za 60 sekund.
Gdy wybierzemy opcje usuwania wybranych plików, wyświetlona zostaje ponumerowana lista plików. Podanie
cyfry/liczby większej niż możliwe do wyboru na liście bądź podanie znaku nie będącego cyfra zamyka skrypt. Dane
musza być podawane pojedynczo, inaczej analogicznie skrypt zostaje zamknięty. Wybrane pliki są zapisywane do pliku
check.txt. Skrypt automatycznie oblicza ile pamięci trzeba zwolnic, by zejść poniżej wartości granicznej. Wymusza na
użytkowniku wybieranie plików, aż ta wartość zostanie osiągnięta. Po stworzeniu listy, skrypt przechodzi do usuwania
plików. Podczas usuwania wyświetla je kolejno użytkownikowi, informując o zakończeniu działania. Zapisuje listę
z usuniętymi plikami pod nazwą hdguard_data_godzina.deleted.
Przy każdej instrukcji warunkowej, zostają wyświetlane stosowane komunikaty.
Po zakończeniu tych działań (bez błędów podczas działania skryptu), wszystkie kroki zostaną wykonane ponownie (bez
podawania wartości granicznej) za 60 sekund, dysk zostanie monitorowany.
W przypadku nieoczekiwanego wyjścia ze skryptu, uruchamia się „pułapka”, która usuwa, jeśli istnieją pliki
pomocnicze(check.txt, tmp), aby nie zostały w nich śmieci, a następnie zamyka skrypt. </p>
