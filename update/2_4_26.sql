-- Miglioramento supporto autenticazione OAuth 2
ALTER TABLE `em_accounts` ADD `oauth2_config` TEXT;

-- Aggiunto sistema di gestione Combinazioni Articoli
CREATE TABLE IF NOT EXISTS `mg_attributi` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `nome` varchar(255) NOT NULL,
    `titolo` varchar(255) NOT NULL,
    `ordine` int(11) NOT NULL,
    `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at` timestamp NULL DEFAULT NULL,
    PRIMARY KEY(`id`)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `mg_valori_attributi` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `id_attributo` int(11) NOT NULL,
    `nome` varchar(255) NOT NULL,
    `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at` timestamp NULL DEFAULT NULL,
    PRIMARY KEY(`id`),
    FOREIGN KEY (`id_attributo`) REFERENCES `mg_attributi`(`id`)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `mg_combinazioni` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `codice` varchar(255) NOT NULL,
    `nome` varchar(255) NOT NULL,
    `id_categoria` int(11),
    `id_sottocategoria` int(11),
    `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at` timestamp NULL DEFAULT NULL,
    PRIMARY KEY(`id`),
    FOREIGN KEY (`id_categoria`) REFERENCES `mg_categorie`(`id`) ON DELETE SET NULL,
    FOREIGN KEY (`id_sottocategoria`) REFERENCES `mg_categorie`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `mg_attributo_combinazione` (
    `id_combinazione` int(11) NOT NULL,
    `id_attributo` int(11) NOT NULL,
    `order` int(11) NOT NULL,
    `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY(`id_attributo`, `id_combinazione`),
    FOREIGN KEY (`id_attributo`) REFERENCES `mg_attributi`(`id`),
    FOREIGN KEY (`id_combinazione`) REFERENCES `mg_combinazioni`(`id`)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `mg_articolo_attributo` (
    `id_articolo` int(11) NOT NULL,
    `id_valore` int(11) NOT NULL,
    `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY(`id_articolo`, `id_valore`),
    FOREIGN KEY (`id_articolo`) REFERENCES `mg_articoli`(`id`),
    FOREIGN KEY (`id_valore`) REFERENCES `mg_valori_attributi`(`id`)
) ENGINE=InnoDB;

ALTER TABLE mg_articoli ADD `id_combinazione` int(11), ADD FOREIGN KEY (`id_combinazione`) REFERENCES `mg_combinazioni`(`id`);

INSERT INTO `zz_modules` (`id`, `name`, `title`, `directory`, `options`, `options2`, `icon`, `version`, `compatibility`, `order`, `parent`, `default`, `enabled`) VALUES
(NULL, 'Attributi Combinazioni', 'Attributi Combinazioni', 'attributi_combinazioni', 'SELECT |select| FROM mg_attributi WHERE mg_attributi.deleted_at IS NULL AND 1=1 HAVING 2=2', NULL, 'fa fa-angle-right', '1.0', '2.*', '100', '20', '1', '1'),
(NULL, 'Combinazioni', 'Combinazioni', 'combinazioni_articoli', 'SELECT |select| FROM mg_combinazioni WHERE mg_combinazioni.deleted_at IS NULL AND 1=1 HAVING 2=2', NULL, 'fa fa-angle-right', '1.0', '2.*', '100', '20', '1', '1');

INSERT INTO `zz_plugins` (`id`, `name`, `title`, `idmodule_from`, `idmodule_to`, `position`, `directory`, `options`) VALUES
(NULL, 'Varianti Articolo', 'Varianti Articolo', (SELECT `id` FROM `zz_modules` WHERE `name`='Articoli'), (SELECT `id` FROM `zz_modules` WHERE `name`='Articoli'), 'tab', 'varianti_articolo', 'custom');

-- Aggiunta colonne per il nuovo modulo Attributi Combinazioni
INSERT INTO `zz_views` (`id`, `id_module`, `name`, `query`, `order`, `visible`, `format`, `default`) VALUES
(NULL, (SELECT `id` FROM `zz_modules` WHERE `name` = 'Attributi Combinazioni'), 'id', 'mg_attributi.id', 1, 0, 0, 1),
(NULL, (SELECT `id` FROM `zz_modules` WHERE `name` = 'Attributi Combinazioni'), 'Nome', 'mg_attributi.nome', 2, 1, 0, 1),
(NULL, (SELECT `id` FROM `zz_modules` WHERE `name` = 'Combinazioni'), 'id', 'mg_combinazioni.id', 1, 0, 0, 1),
(NULL, (SELECT `id` FROM `zz_modules` WHERE `name` = 'Combinazioni'), 'Nome', 'mg_combinazioni.nome', 2, 1, 0, 1);

-- Introduzione della Banca nelle tabelle Fatture
INSERT INTO `zz_views` (`id_module`, `name`, `query`, `order`, `search`, `slow`, `default`) VALUES
((SELECT `id` FROM `zz_modules` WHERE `name` = 'Fatture di vendita'), 'Banca', '(SELECT CONCAT(co_banche.nome, '' - '' , co_banche.iban) AS descrizione FROM co_banche WHERE co_banche.id = id_banca_azienda)', 6, 1, 0, 1),
((SELECT `id` FROM `zz_modules` WHERE `name` = 'Fatture di acquisto'), 'Banca',
'(SELECT CONCAT(co_banche.nome, '' - '' , co_banche.iban) FROM co_banche WHERE co_banche.id = id_banca_azienda)', 6, 1, 0, 1);

-- Rimosso reversed sulle note di debito
UPDATE `co_tipidocumento` SET `reversed` = '0' WHERE `co_tipidocumento`.`descrizione` = 'Nota di debito';

-- Fix recupero informazioni sui servizi attivi
UPDATE `zz_cache` SET `expire_at` = NULL WHERE `zz_cache`.`name` = 'Informazioni su Services';

-- Fix flag default per i plugin
UPDATE `zz_plugins` SET `default` = 1, `version` = '' WHERE `zz_plugins`.`name` IN ('Impianti del cliente', 'Impianti', 'Referenti', 'Sedi', 'Statistiche', 'Interventi svolti', 'Componenti ini', 'Movimenti', 'Serial', 'Consuntivo', 'Consuntivo', 'Pianificazione interventi', 'Ddt del cliente', 'Fatturazione Elettronica', 'Fatturazione Elettronica', 'Revisioni', 'Ricevute FE', 'Giacenze', 'Rinnovi', 'Statistiche', 'Dichiarazioni d''Intento', 'Pianificazione fatturazione', 'Listino Clienti', 'Storico attività', 'Consuntivo', 'Allegati', 'Componenti', 'Listino Fornitori', 'Piani di sconto/maggiorazione', 'Varianti Articolo');

-- Escludo dalla lista movimenti quelli collegati ad articoli eliminati
UPDATE `zz_modules` SET `options` = 'SELECT |select| FROM `mg_movimenti` JOIN `mg_articoli` ON `mg_articoli`.id = `mg_movimenti`.`idarticolo` LEFT JOIN `an_sedi` ON `mg_movimenti`.`idsede` = `an_sedi`.`id` WHERE 1=1 AND mg_articoli.deleted_at IS NULL HAVING 2=2 ORDER BY mg_movimenti.data DESC, mg_movimenti.created_at DESC' WHERE `zz_modules`.`name` = 'Movimenti';

-- Aggiunta eliminazione causale DDT
ALTER TABLE `dt_causalet` ADD `deleted_at` TIMESTAMP NULL AFTER `updated_at`;

-- Modifico il filtro del modulo
UPDATE `zz_modules` SET `options` = 'SELECT |select| FROM `dt_causalet` WHERE 1=1 AND `deleted_at` IS NULL HAVING 2=2' WHERE `zz_modules`.`name` = 'Causali';

-- Aggiunto nuovo sistema di gestione Scadenze
CREATE TABLE IF NOT EXISTS `co_gruppi_scadenze` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `id_documento` int(11) DEFAULT NULL,
    `descrizione` varchar(255) NOT NULL,
    `note` TEXT,
    `data_emissione` date DEFAULT NULL,
    `totale_pagato` decimal(12, 6) NOT NULL,
    `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY(`id`),
    FOREIGN KEY (`id_documento`) REFERENCES `co_documenti`(`id`)
) ENGINE=InnoDB;

ALTER TABLE `co_scadenze` RENAME TO `co_scadenze`;
ALTER TABLE `co_scadenze` ADD `id_gruppo` INT(11), ADD FOREIGN KEY (`id_gruppo`) REFERENCES `co_gruppi_scadenze`(`id`);

ALTER TABLE `co_gruppi_scadenze` ADD `id_scadenza_origine` INT(11);

-- Inserimento gruppi per Documenti
INSERT INTO `co_gruppi_scadenze` (`id_scadenza_origine`, `id_documento`, `descrizione`, `data_emissione`, `totale_pagato`) SELECT `id`, `iddocumento`, `descrizione`, `data_emissione`, SUM(`pagato`) FROM `co_scadenze` WHERE `iddocumento` != 0 GROUP BY `iddocumento`;

UPDATE `co_scadenze` INNER JOIN `co_gruppi_scadenze` ON `co_scadenze`.`iddocumento` = `co_gruppi_scadenze`.`id_documento` SET `co_scadenze`.`id_gruppo` =  `co_gruppi_scadenze`.`id`;

-- Inserimento gruppi per Scadenze indipendenti
INSERT INTO `co_gruppi_scadenze` (`id_scadenza_origine`, `id_documento`, `descrizione`, `data_emissione`, `totale_pagato`) SELECT `id`, `iddocumento`, `descrizione`, `data_emissione`, `pagato` FROM `co_scadenze` WHERE `iddocumento` = 0;

UPDATE `co_scadenze` INNER JOIN `co_gruppi_scadenze` ON `co_scadenze`.`id` = `co_gruppi_scadenze`.`id_scadenza_origine` SET `co_scadenze`.`id_gruppo` =  `co_gruppi_scadenze`.`id`;

-- ALTER TABLE `co_gruppi_scadenze` DROP `id_scadenza_origine`;

-- Correzioni per il modulo Scadenzario
UPDATE `zz_modules` SET `options` = 'SELECT |select| FROM `co_scadenze`
    INNER JOIN `co_gruppi_scadenze` ON `co_gruppi_scadenze`.`id` = `co_scadenze`.`id_gruppo`
    LEFT JOIN `co_documenti` ON `co_gruppi_scadenze`.`id_documento` = `co_documenti`.`id`
    LEFT JOIN `an_anagrafiche` ON `co_documenti`.`idanagrafica` = `an_anagrafiche`.`idanagrafica`
    LEFT JOIN `co_pagamenti` ON `co_documenti`.`idpagamento` = `co_pagamenti`.`id`
    LEFT JOIN `co_tipidocumento` ON `co_documenti`.`idtipodocumento` = `co_tipidocumento`.`id`
    LEFT JOIN `co_statidocumento` ON `co_documenti`.`idstatodocumento` = `co_statidocumento`.`id`
WHERE 1=1 AND
    (`co_statidocumento`.`descrizione` IS NULL OR `co_statidocumento`.`descrizione` IN(''Emessa'',''Parzialmente pagato'',''Pagato''))
HAVING 2=2
ORDER BY `co_scadenze`.`scadenza` ASC' WHERE `zz_modules`.`name` = 'Scadenzario';

INSERT INTO `zz_views` (`id`, `id_module`, `name`, `query`, `order`, `visible`, `format`) VALUES
(NULL, (SELECT `id` FROM `zz_modules` WHERE `name` = 'Scadenzario'), '_link_record_', 'co_gruppi_scadenze.id', 0, 0, 0),
(NULL, (SELECT `id` FROM `zz_modules` WHERE `name` = 'Scadenzario'), '_link_hash_', 'CONCAT(''scadenza_'', co_scadenze.id)', 0, 0, 0);

UPDATE `zz_views` SET `query` = 'co_scadenze.scadenza' WHERE `name` = 'Data scadenza' AND `id_module` = (SELECT `id` FROM `zz_modules` WHERE name = 'Scadenzario');

UPDATE `zz_views` SET `query` = 'co_scadenze.id' WHERE `name` = 'id' AND `id_module` = (SELECT `id` FROM `zz_modules` WHERE name = 'Scadenzario');

UPDATE `zz_views` SET `query` = 'co_gruppi_scadenze.data_emissione' WHERE `name` = 'Data emissione' AND `id_module` = (SELECT `id` FROM `zz_modules` WHERE name = 'Scadenzario');

UPDATE `zz_views` SET `query` = 'co_scadenze.da_pagare' WHERE `name` = 'Importo' AND `id_module` = (SELECT `id` FROM `zz_modules` WHERE name = 'Scadenzario');

UPDATE `zz_views` SET `query` = 'co_scadenze.pagato' WHERE `name` = 'Pagato' AND `id_module` = (SELECT `id` FROM `zz_modules` WHERE name = 'Scadenzario');

UPDATE `zz_views` SET `query` = 'co_gruppi_scadenze.descrizione' WHERE `name` = 'Descrizione scadenza' AND `id_module` = (SELECT `id` FROM `zz_modules` WHERE name = 'Scadenzario');

UPDATE `zz_views` SET `query` = 'IF(an_anagrafiche.ragione_sociale IS NULL, co_gruppi_scadenze.descrizione, an_anagrafiche.ragione_sociale)' WHERE `name` = 'Anagrafica' AND `id_module` = (SELECT `id` FROM `zz_modules` WHERE name = 'Scadenzario');

UPDATE `zz_views` SET `query` = 'co_scadenze.note' WHERE `name` = 'Note' AND `id_module` = (SELECT `id` FROM `zz_modules` WHERE name = 'Scadenzario');

UPDATE `zz_widgets` SET `query` = REPLACE(`query`, 'co_scadenziario', 'co_scadenze');
UPDATE `zz_segments` SET `clause` = REPLACE(`clause`, 'co_scadenziario', 'co_scadenze');
