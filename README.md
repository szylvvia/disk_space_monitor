<h1> HDGUARD - disk space monitor </h1>
<p><i>Shell script</i></p>

<h2>Opis działania</h2>
<p align="justify">
Skrypt ten ma za zadanie monitorować dysk lub określoną partycję co 60 sekund. W przypadku nieprawidłowych wartości podanych podczas uruchamiania skryptu, zostanie on automatycznie zamknięty. Wartość musi być liczbą z przedziału otwartego (30;99), a skrypt akceptuje tylko jedną wartość. Wartość graniczna jest pobierana podczas wywoływania skryptu.</p>
<p align="justify">
Skrypt zbiera informacje o partycji i wyświetla je użytkownikowi. Następnie oblicza, ile pamięci należy zwolnić, aby zejść poniżej wartości granicznej. Skrypt wyszukuje i wyświetla listę plików, które można usunąć, a użytkownik ma możliwość wyboru, które z nich chce usunąć. Po wyborze, skrypt automatycznie usuwa wybrane pliki i informuje użytkownika o zakończeniu działania. </p>
<p align="justify">
Aby korzystać ze skryptu, należy uruchomić go, podając wartość graniczną przy wywoływaniu.</p>
