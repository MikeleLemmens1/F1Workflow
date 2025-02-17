# Opdracht Data-Workflow

Deze workflow maakt deel uit van het vak Linux For Data Scientists - MT2SEM2 van Toegepaste Informatica aan HOGENT.
Het stelt een pipeline voor die F1-data downloadt en verwerkt om tot slot een webpagina te genereren die "live" rondetijden toont.
Eigen aan deze workflow is dat de volledige codebase gebruik maakt van shell scripts, geen python of andere programmeertaal.

## Keuze dataset en persoonlijke doelstelling

Ik ben fan van motorsport, en in het bijzonder van Formule 1. Wanneer ik naar een race kijk vind ik het leuk om in real-time de rondetijden te kunnen bekijken. Deze feature is vandaag de dag verkrijgbaar bij verschillende zenders, maar altijd tegen betaling. Omdat ik maar een arme student ben heb ik besloten om dit zelf te maken. Het doel is een overzicht te hebben van iedere rondetijd van iedere piloot in een lopende race (en dat dit overzicht leesbaar is voor niet-IT'ers).

## Proces

Ik heb geen enkele ervaring met dataverwerking of programmeren in bash of python, dus was het moeilijk in te schatten wat er al dan niet realistisch is. Om deze reden ben ik met een basis begonnen in het grafisch weergeven van alle rondetijden van 1 piloot voor 1 race. Vervolgens was het nodig om 1 overzicht te krijgen van alle piloten, zodanig dat je makkelijk de rondes kan vergelijken tussen verschillende piloten. Deze 2 stappen heb ik gecombineerd in 2 bash-scripts met ieder een .gnu-script (voor het plotten).

Na deze laatste stap zat ik een beetje vast. Mijn data wordt nl. niet live bijgewerkt, dus is het niet mogelijk om rondetijden in realtime te analyseren. Toch zal er wel ergens een bron zijn die deze data wél live binnenkrijgt, dus heb ik besloten om livedata na te bootsen (om dus ook mijn automatisatieskills te kunnen demonstreren). Dit gebeurt in een apart script, waarin mijn rauwe data mondjesmaat wordt gevoed alsof deze in realtime binnenkomt.

Uiteraard begin ik dit hele proces met het binnenhalen van mijn data. Alle scripts zijn samengevoegd in een overkoepelend script waarmee de ganse bewerking kan worden uitgevoerd zonder al te veel tussenkomst van de gebruiker. Je wil nl. niet heel de tijd op je computer bezig zijn als er een race gaande is, toch?

## Dataset

Ik maak gebruik van 1 enkele dataset. Deze haal ik op als zip-file van de Ergast F1 API. Na JSON te hebben uitgeprobeerd ben ik overgeschakeld op CSV-files. De data bestaat uit een relationele dataset van CSV's die naar elkaar wijzen adhv vreemde sleutels. Omdat ik voor iedere analyse verschillende tabellen met elkaar moet combineren lijkt deze mij voldoende complex te zijn.

De gedownloade zip-file wordt opgeslagen in een map naar keuze van de gebruiker (aan te passen binnen het script refresh_data). Vervolgens wordt deze file uitgepakt naar een map (`csv_files/raw`) en voorzien van een timestamp. Deze zip-file, net als alle bestanden in de map `raw` worden niet verwijderd noch aangepast. Alle gegenereerde CSV-files worden opgeslagen in een aparte map (`csv_files/processed`).

## Scripts

Mijn scripts zijn geschreven in Bash, en voor het plotten heb ik .gnu-files gemaakt.
Hier is een overzicht van mijn geschreven scripts, te vinden in `./scripts/`:

- Bash-scripts
  - `refresh_data.sh`
  - `toon_rondetijd_alle_piloten.sh`
  - `toon_rondetijden.sh`
  - `genereer_live_data.sh`
  - `main.sh`
- GNUplot
  - `plot_data.gnu`
  - `plot_data_all.gnu`
  - `plot_data_live.gnu`

Ieder script is voorzien van commentaar waarin de werking wordt uitgelegd. Ook de vereiste opties en/of variabelen worden beschreven. Het script `main.sh` voert de ganse pipeline uit zonder opties of andere tussenkomst. Daarnaast is het mogelijk om ieder bash-script apart uit te voeren mits enkele richtlijnen die hieronder beschreven worden.

## Workflow

Het `main`-script voert alle scripts uit en voorziet korte pauzes zodat de taken juist gesynchroniseerd worden. Zorg dat je je in de `data-workflow`-directory bevindt, alle gebruikte paden zijn relatief. Je begint met een directory met enkel de submappen `logs` en `scripts`. Om de scripts apart te kunnen uitvoeren in de command line dien je volgende richtlijnen in acht te nemen:

1) Als je al eerder refresh_data.sh hebt uitgevoerd dien je best de map `./csv_files` en `./plots` te verwijderen. Mijn scripts verwijderen deze files normaal gezien wel, maar toch verloopt de flow vaak niet zoals gehoopt als deze mappen nog aanwezig zijn. Wanneer je alle scripts afzonderlijk uitvoert komt dit probleem niet voor.

2) Begin met `./scripts/refresh_data.sh` Deze maakt je directory verder klaar. Wanneer je alle scripts na elkaar uitvoert, zorg dan dat dit script eerst klaar is voordat je aan andere scripts begint. Oude files worden opgeruimd zodat je altijd met de meest recente data werkt.<br>

3) Als de data klaar staat kan je de rondetijd voor een gekozen race en piloot kiezen (`./scripts/toon_rondetijden.sh Alonso 2011 5`). Deze data geef je in zoals een gebruiker het kan begrijpen, een piloot definieer je adhv zijn achternaam (bv. "Alonso"), het seizoen is het jaartal, en de ronde is de nummer van de race van dat seizoen. De naam van een race is dubbelzinnig, een rondenummer niet (en wordt steeds meegegeven zoals in de afbeelding hieronder), vandaar dat ik een race op die manier identificeer.<br>
![Racenaam en rondenummer](image.png)\
Wanneer ongeldige argumenten worden meegegeven wordt er een foutmelding gelogd en breekt het script af, het is nl. niet mogelijk om een analyse te maken van een ongeldig verzoek.
Na het maken van de nodige CSV-files wordt een grafiek gemaakt en ingevoegd in de map `./plots/`.

4) Als je graag wil weten hoe je piloot het stelt tegenover de andere piloten kan je het overzicht opvragen van alle piloten met de optie `-a` ipv de naam van de piloot: `./scripts/toon_rondetijden.sh -a 2011 5`. Hetzelfde resultaat kan je bereiken door het script meteen aan te roepen (`./scripts/toon_rondetijd_alle_piloten.sh 845 2011 5`), maar let dan op dat je enerzijds het **raceId** meegeeft als eerste argument en weet dat het plotten van de data wordt opgeroepen in het vorig script. Ook heeft dit script nagenoeg geen error handling omdat dit normaliter door mijn ander script wordt opgeroepen.

5) `./scripts/genereer_live_data.sh` doet dezelfde datatransformatie als mijn vorige scripts, maar levert iedere seconde een beetje nieuwe data in de liveTiming-file. De rondetijden worden per piloot bijgehouden in aparte files die in realtime bijgevuld worden. Om te testen kan je dit script aanroepen om vervolgens de file `./csv_files/processed/liveTiming.csv` in de gaten te houden, je zal zien dat deze groeit alsof er een live race bezig is. Omdat er ten allen tijde maar 1 race live bezig kan zijn heeft dit script geen argumenten nodig, de juiste id's worden opgezocht en gebruikt.

6) Wanneer je via het main-script werkt zal je zien dat deze live data wordt geplot (`YYYYRRLive.png`), met YYYY het seizoen en RR het rondenummer. Omdat het seizoen afgelopen is zal dit tot nader order `202323Live.png` zijn, de GP van Abu Dhabi 2023. Om dit resultaat bruikbaar te maken voor de doorsnee F1-fan heb ik ervoor gekozen om de gemaakte grafiek te publiceren op een webpagina gehost vanop mijn linux-machine (apacheserver). Ik heb een webroot gemaakt waarin ik alle gemaakte grafieken kopieer, om dan via een img-tag de gewenste grafiek te bekijken. Deze webpagina ververst om de seconde, waardoor de grafiek mee groeit naargelang de wedstrijd vordert, en zo de live timing van alle piloten toont. Doel bereikt!

Overzicht van de commando's:

```bash
./scripts/refresh_data.sh
./scripts/toon_rondetijden.sh Alonso 2011 5
./scripts/toon_rondetijden.sh -a 2011 5
./scripts/genereer_live_data.sh
```
