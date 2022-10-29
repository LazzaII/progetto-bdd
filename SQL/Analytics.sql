USE SmartBuildings;

/*
CONSIGLI DI INTERVENTO
A fronte dell’analisi dei dati dei sensori, un sistema intelligente, realizzato tramite
una o più procedure di back-end, studia i valori misurati nel tempo dai sensori e
propone interventi (lavori) da fare sull’edificio in base a considerazioni euristiche
scelte dagli studenti. I lavori possono essere, per esempio, installazione di giunti,
rifacimento/consolidamento di solai, coperture, oppure altre ristrutturazioni. I consigli
devono essere corredati da un coefficiente di rischio di danno alle strutture che
ne definisca l’urgenza tramite un codice di priorità.
A titolo di esempio, il sistema potrebbe suggerire che, se non si consolida una
determinata parte danneggiata dell’edificio, dopo un certo tempo oppure dopo un
evento calamitoso caratterizzato da sollecitazioni superiori a determinate soglie, c’è
una determinata probabilità che si verifichi un crollo a seguito del quale una certa
spesa sarebbe necessaria. I termini in italico corrispondono ai valori numerici che il
sistema dovrebbe stimare.
*/




/*
STIMA DEI DANNI
Questa funzionalità si occupa di effettuare la predizione di danni a seguito di eventi
sismici, a partire da un’ipotetica sollecitazione e dallo stato dell’edificio.

Gli studenti devono studiare e implementare una funzionalità che stimi i potenziali
danni alle parti di un edificio, sfruttando i dati misurati dai sensori e i danni arrecati
all’edificio provocati da precedenti sollecitazioni sismiche reali.
*/