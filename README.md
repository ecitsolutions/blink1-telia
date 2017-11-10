# Blink1-Telia 

## Krav for programvaren
- Blink(1) USB lys
- Windows med Powershell
- Internett-tilkobling
- Tilgang på Telia sentralbord (Bedrift)

### Installasjon

 1. Last ned zip filen [her](https://github.com/ljskatt/Blink1-Telia/releases)
 2. Kjør install.ps1
 3. Scriptet vil spørre deg om du vil ha en snarvei på skrivebordet.

### Konfigurasjon

Konfigurasjonsfil:<br>
`C:\Users\<YOURUSER>\AppData\Roaming\Blink1-Telia\config.json`

| Konfigurasjonsnavn | Beskrivelse |
| ------------------ | ----------- |
| blink1-delay | Antall millisekunder lyset bruker på å skifte farge (Standard: 600) |

<br>
Du kan bruke install scriptet for å sette Blink-Delay til ønsket verdi:

> ./install.ps1 "800"
<br>

Du kan også bruke det på hovedscriptet som er lokalisert under:<br>
`C:\Users\<YOURUSER>\AppData\Roaming\Blink1-Telia\main.ps1`

> ./main.ps1 "800"

## Bruk av scriptet

Når du starter scriptet, så blir du spurt om ditt Telia Sentralbord Brukernavn og Passord.<br>
Om innloggingen er vellykket, så vil et vindu med 5 knapper dukke opp.<br>

### Telia status

Om du trykker på "Telia status", så vil den starte en bakgrunnsprosess som da vil hente din status hvert 3. sekund.<br>
Om du ikke er i en samtale, så vil Blink(1) lyse Grønt.<br>
Men om du er i en samtale, så vil Blink(1) lyse Rødt.<br>

### Manuell farge

Det er 3 knapper som du kan bruke til å sette en manuell farge.
- Ledig (Grønn)
- Opptatt (Rød)
- Kake (Blå)

Disse knappene kan man såklart endre på som man vil, men det må da endres på i koden (avansert). 

### Avslutt

Denne knappen vil avslutte "Telia Status" bakgrunnsprosessen (om den kjører), og vil lukke menyen.<br>
Dette anbefales når du skal avslutte programmet, eller så kan man risikere at "Telia Status" fortsatt kjører i bakgrunnen.

## License og programvare

'blink(1)' er et varemerke av ThingM Corporation

Blink1-Telia er bygd oppå [todbot sin blink1-tool.exe](https://github.com/todbot/blink1), exe filen blir lastet ned automatisk av Blink1-Telia under installasjon.

License: [CC BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/)
Todbot sin [License](https://github.com/todbot/blink1/blob/master/LICENSE.txt) 

[Blink1-Telia License](https://github.com/ljskatt/Blink1-Telia/blob/master/LICENSE.txt)