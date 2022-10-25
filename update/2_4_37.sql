-- Aggiunta colonna Pagamento in Fatture
UPDATE `zz_modules` SET `options` = 'SELECT |select| FROM `co_documenti`\n    LEFT JOIN `an_anagrafiche` ON `co_documenti`.`idanagrafica` = `an_anagrafiche`.`idanagrafica`\n    LEFT JOIN `co_tipidocumento` ON `co_documenti`.`idtipodocumento` = `co_tipidocumento`.`id`\n    LEFT JOIN `co_statidocumento` ON `co_documenti`.`idstatodocumento` = `co_statidocumento`.`id`\n    LEFT JOIN `fe_stati_documento` ON `co_documenti`.`codice_stato_fe` = `fe_stati_documento`.`codice`\n    LEFT JOIN `co_ritenuta_contributi` ON `co_documenti`.`id_ritenuta_contributi` = `co_ritenuta_contributi`.`id`\n    LEFT JOIN `co_pagamenti` ON `co_documenti`.`idpagamento` = `co_pagamenti`.`id`\n    LEFT JOIN (\n        SELECT `iddocumento`,\n            SUM(`subtotale` - `sconto`) AS `totale_imponibile`,\n                SUM(`iva`) AS `iva`\n         FROM `co_righe_documenti`\n        GROUP BY `iddocumento`\n    ) AS righe ON `co_documenti`.`id` = `righe`.`iddocumento`\n    LEFT JOIN (\n        SELECT `numero_esterno`, `id_segment`, `idtipodocumento`, `data`\n        FROM `co_documenti`\n        WHERE `co_documenti`.`idtipodocumento` IN(SELECT `id` FROM `co_tipidocumento` WHERE `dir` = \'entrata\') |date_period(`co_documenti`.`data`)| AND `numero_esterno` != \'\'\n        GROUP BY `id_segment`, `numero_esterno`, `idtipodocumento`, `data`\n        HAVING COUNT(`numero_esterno`) > 1\n    ) dup ON `co_documenti`.`numero_esterno` = `dup`.`numero_esterno` AND `dup`.`id_segment` = `co_documenti`.`id_segment` AND `dup`.`idtipodocumento` = `co_documenti`.`idtipodocumento` AND `dup`.`data` = `co_documenti`.`data`\n    LEFT JOIN (\n        SELECT `zz_operations`.`id_email`, `zz_operations`.`id_record`\n        FROM `zz_operations`\n            INNER JOIN `em_emails` ON `zz_operations`.`id_email` = `em_emails`.`id`\n            INNER JOIN `em_templates` ON `em_emails`.`id_template` = `em_templates`.`id`\n            INNER JOIN `zz_modules` ON `zz_operations`.`id_module` = `zz_modules`.`id`\n        WHERE `zz_modules`.`name` = \'Fatture di vendita\' AND `zz_operations`.`op` = \'send-email\'\n        GROUP BY `zz_operations`.`id_record`\n    ) AS `email` ON `email`.`id_record` = `co_documenti`.`id`\nWHERE 1=1 AND `dir` = \'entrata\' |segment(`co_documenti`.`id_segment`)| |date_period(`co_documenti`.`data`)|\nHAVING 2=2\nORDER BY `co_documenti`.`data` DESC, CAST(`co_documenti`.`numero_esterno` AS UNSIGNED) DESC' WHERE `zz_modules`.`name` = 'Fatture di vendita';


UPDATE `zz_modules` SET `options` = 'SELECT |select| FROM `co_documenti`\nLEFT JOIN `an_anagrafiche` ON `co_documenti`.`idanagrafica` = `an_anagrafiche`.`idanagrafica`\nLEFT JOIN `co_tipidocumento` ON `co_documenti`.`idtipodocumento` = `co_tipidocumento`.`id`\nLEFT JOIN `co_statidocumento` ON `co_documenti`.`idstatodocumento` = `co_statidocumento`.`id`\nLEFT JOIN `co_ritenuta_contributi` ON `co_documenti`.`id_ritenuta_contributi` = `co_ritenuta_contributi`.`id`\nLEFT JOIN `co_pagamenti` ON `co_documenti`.`idpagamento` = `co_pagamenti`.`id`\nLEFT JOIN (\n    SELECT `iddocumento`,\n    SUM(`subtotale` - `sconto`) AS `totale_imponibile`,\n    SUM(`iva`) AS `iva`\n    FROM `co_righe_documenti`\n    GROUP BY `iddocumento`\n) AS righe ON `co_documenti`.`id` = `righe`.`iddocumento`\nLEFT JOIN (\n    SELECT COUNT(`d`.`id`) AS `conteggio`,\n        IF(`d`.`numero_esterno`=\'\', `d`.`numero`, `d`.`numero_esterno`) AS `numero_documento`,\n        `d`.`idanagrafica` AS `anagrafica`,\n        `id_segment`\n    FROM `co_documenti` AS `d`\n    LEFT JOIN `co_tipidocumento` AS `d_tipo` ON `d`.`idtipodocumento` = `d_tipo`.`id`\n    WHERE 1=1\n        AND `d_tipo`.`dir` = \'uscita\'\n        AND (\'|period_start|\' <= `d`.`data` AND \'|period_end|\' >= `d`.`data` OR \'|period_start|\' <= `d`.`data_competenza` AND \'|period_end|\' >= `d`.`data_competenza`)\n        GROUP BY  `id_segment`, `numero_documento`, `d`.`idanagrafica`\n) AS `d` ON (`d`.`numero_documento` = IF(`co_documenti`.`numero_esterno`=\'\', `co_documenti`.`numero`, `co_documenti`.`numero_esterno`) AND `d`.`anagrafica`=`co_documenti`.`idanagrafica` AND `d`.`id_segment` = `co_documenti`.`id_segment`)\nWHERE 1=1 AND `dir` = \'uscita\' |segment(`co_documenti`.`id_segment`)||date_period(custom, \'|period_start|\' <= `co_documenti`.`data` AND \'|period_end|\' >= `co_documenti`.`data`, \'|period_start|\' <= `co_documenti`.`data_competenza` AND \'|period_end|\' >= `co_documenti`.`data_competenza` )|\nHAVING 2=2\nORDER BY `co_documenti`.`data` DESC, CAST(IF(`co_documenti`.`numero` = \'\', `co_documenti`.`numero_esterno`, `co_documenti`.`numero`) AS UNSIGNED) DESC' WHERE `zz_modules`.`name` = 'Fatture di acquisto';

INSERT INTO `zz_views` (`id_module`, `name`, `query`, `order`, `search`, `slow`, `format`, `html_format`, `search_inside`, `order_by`, `visible`, `summable`, `default`) VALUES
((SELECT `id` FROM `zz_modules` WHERE `name`='Fatture di vendita'), 'Pagamento', 'CONCAT(co_pagamenti.codice_modalita_pagamento_fe, \" - \", co_pagamenti.descrizione)', 13, 1, 0, 0, 0, '', '', 0, 0, 1);

INSERT INTO `zz_views` (`id_module`, `name`, `query`, `order`, `search`, `slow`, `format`, `html_format`, `search_inside`, `order_by`, `visible`, `summable`, `default`) VALUES
((SELECT `id` FROM `zz_modules` WHERE `name`='Fatture di acquisto'), 'Pagamento', 'CONCAT(co_pagamenti.codice_modalita_pagamento_fe, \" - \", co_pagamenti.descrizione)', 13, 1, 0, 0, 0, '', '', 0, 0, 1);

-- Aggiunto modulo Mappa
INSERT INTO `zz_modules` (`id`, `name`, `title`, `directory`, `options`, `options2`, `icon`, `version`, `compatibility`, `order`, `parent`, `default`, `enabled`, `created_at`, `updated_at`, `use_notes`, `use_checklists`) VALUES (NULL, 'Mappa', 'Mappa', 'mappa', 'custom', '', 'fa fa-map', '2.4.36', '2.4.36', '10', NULL, '1', '1', '2022-10-12 17:22:11', '2022-10-12 17:23:52', '0', '0');

-- Aggiunte colonne cellulare e indirizzo in Anagrafiche
INSERT INTO `zz_views` (`id_module`, `name`, `query`, `order`, `search`, `slow`, `format`, `html_format`, `search_inside`, `order_by`, `visible`, `summable`, `default`) VALUES
((SELECT `id` FROM `zz_modules` WHERE `name`='Anagrafiche'), 'Indirizzo', 'an_anagrafiche.indirizzo', 13, 1, 0, 0, 0, '', '', 0, 0, 1);

INSERT INTO `zz_views` (`id_module`, `name`, `query`, `order`, `search`, `slow`, `format`, `html_format`, `search_inside`, `order_by`, `visible`, `summable`, `default`) VALUES
((SELECT `id` FROM `zz_modules` WHERE `name`='Anagrafiche'), 'Cellulare', 'an_anagrafiche.cellulare', 14, 1, 0, 0, 0, '', '', 0, 0, 1);

-- Aggiunto colore in Stati Preventivi
ALTER TABLE `co_statipreventivi` ADD `colore` VARCHAR(7) NOT NULL AFTER `icona`; 

INSERT INTO `zz_views` (`id_module`, `name`, `query`, `order`, `search`, `slow`, `format`, `html_format`, `search_inside`, `order_by`, `visible`, `summable`, `default`) VALUES
((SELECT `id` FROM `zz_modules` WHERE `name`='Preventivi'), '_bg_', 'co_statipreventivi.colore', 10, 0, 0, 0, 0, '', '', 0, 0, 1);

INSERT INTO `zz_views` (`id_module`, `name`, `query`, `order`, `search`, `slow`, `format`, `html_format`, `search_inside`, `order_by`, `visible`, `summable`, `default`) VALUES
((SELECT `id` FROM `zz_modules` WHERE `name`='Stati dei preventivi'), 'color_Colore', 'colore', 7, 1, 0, 0, 0, '', '', 1, 0, 1);

-- Allineamento decimali 
ALTER TABLE `an_anagrafiche` CHANGE `provvigione_default` `provvigione_default` DECIMAL(15,6) NOT NULL;
ALTER TABLE `co_contratti` CHANGE `budget` `budget` DECIMAL(15,6) NOT NULL, CHANGE `costo_diritto_chiamata` `costo_diritto_chiamata` DECIMAL(15,6) NOT NULL, CHANGE `ore_lavoro` `ore_lavoro` DECIMAL(15,6) NOT NULL, CHANGE `costo_orario` `costo_orario` DECIMAL(15,6) NOT NULL, CHANGE `costo_km` `costo_km` DECIMAL(15,6) NOT NULL; 
ALTER TABLE `co_contratti_tipiintervento` CHANGE `costo_ore` `costo_ore` DECIMAL(15,6) NOT NULL, CHANGE `costo_km` `costo_km` DECIMAL(15,6) NOT NULL, CHANGE `costo_dirittochiamata` `costo_dirittochiamata` DECIMAL(15,6) NOT NULL, CHANGE `costo_ore_tecnico` `costo_ore_tecnico` DECIMAL(15,6) NOT NULL, CHANGE `costo_km_tecnico` `costo_km_tecnico` DECIMAL(15,6) NOT NULL, CHANGE `costo_dirittochiamata_tecnico` `costo_dirittochiamata_tecnico` DECIMAL(15,6) NOT NULL; 
ALTER TABLE `co_dichiarazioni_intento` CHANGE `totale` `totale` DECIMAL(15,6) NOT NULL; 
ALTER TABLE `co_documenti` CHANGE `rivalsainps` `rivalsainps` DECIMAL(15,6) NOT NULL, CHANGE `iva_rivalsainps` `iva_rivalsainps` DECIMAL(15,6) NOT NULL, CHANGE `ritenutaacconto` `ritenutaacconto` DECIMAL(15,6) NOT NULL, CHANGE `bollo` `bollo` DECIMAL(15,6) NULL DEFAULT NULL, CHANGE `ritenuta_contributi` `ritenuta_contributi` DECIMAL(15,6) NOT NULL; 
ALTER TABLE `co_movimenti` CHANGE `totale` `totale` DECIMAL(15,6) NULL DEFAULT NULL, CHANGE `totale_reddito` `totale_reddito` DECIMAL(15,6) NOT NULL DEFAULT '0.000000'; 
ALTER TABLE `co_preventivi` CHANGE `budget` `budget` DECIMAL(15,6) NOT NULL, CHANGE `costo_diritto_chiamata` `costo_diritto_chiamata` DECIMAL(15,6) NOT NULL, CHANGE `ore_lavoro` `ore_lavoro` DECIMAL(15,6) NOT NULL, CHANGE `costo_orario` `costo_orario` DECIMAL(15,6) NOT NULL, CHANGE `costo_km` `costo_km` DECIMAL(15,6) NOT NULL; 
ALTER TABLE `co_provvigioni` CHANGE `provvigione` `provvigione` DECIMAL(15,6) NOT NULL; 
ALTER TABLE `co_righe_contratti` CHANGE `subtotale` `subtotale` DECIMAL(15,6) NOT NULL, CHANGE `sconto` `sconto` DECIMAL(15,6) NOT NULL, CHANGE `sconto_unitario` `sconto_unitario` DECIMAL(15,6) NOT NULL, CHANGE `iva` `iva` DECIMAL(15,6) NOT NULL, CHANGE `iva_indetraibile` `iva_indetraibile` DECIMAL(15,6) NOT NULL, CHANGE `provvigione` `provvigione` DECIMAL(15,6) NOT NULL, CHANGE `provvigione_unitaria` `provvigione_unitaria` DECIMAL(15,6) NOT NULL, CHANGE `provvigione_percentuale` `provvigione_percentuale` DECIMAL(15,6) NOT NULL; 
ALTER TABLE `co_righe_documenti` CHANGE `iva` `iva` DECIMAL(15,6) NOT NULL, CHANGE `iva_indetraibile` `iva_indetraibile` DECIMAL(15,6) NOT NULL, CHANGE `subtotale` `subtotale` DECIMAL(15,6) NOT NULL, CHANGE `sconto` `sconto` DECIMAL(15,6) NOT NULL, CHANGE `sconto_unitario` `sconto_unitario` DECIMAL(15,6) NOT NULL, CHANGE `ritenutaacconto` `ritenutaacconto` DECIMAL(15,6) NOT NULL, CHANGE `rivalsainps` `rivalsainps` DECIMAL(15,6) NOT NULL, CHANGE `provvigione` `provvigione` DECIMAL(15,6) NOT NULL, CHANGE `provvigione_unitaria` `provvigione_unitaria` DECIMAL(15,6) NOT NULL, CHANGE `provvigione_percentuale` `provvigione_percentuale` DECIMAL(15,6) NOT NULL; 
ALTER TABLE `co_righe_preventivi` CHANGE `iva` `iva` DECIMAL(15,6) NOT NULL, CHANGE `iva_indetraibile` `iva_indetraibile` DECIMAL(15,6) NOT NULL, CHANGE `subtotale` `subtotale` DECIMAL(15,6) NOT NULL, CHANGE `sconto` `sconto` DECIMAL(15,6) NOT NULL, CHANGE `sconto_unitario` `sconto_unitario` DECIMAL(15,6) NOT NULL, CHANGE `provvigione` `provvigione` DECIMAL(15,6) NOT NULL, CHANGE `provvigione_unitaria` `provvigione_unitaria` DECIMAL(15,6) NOT NULL, CHANGE `provvigione_percentuale` `provvigione_percentuale` DECIMAL(15,6) NOT NULL; 
ALTER TABLE `co_righe_promemoria` CHANGE `iva` `iva` DECIMAL(15,6) NOT NULL, CHANGE `sconto` `sconto` DECIMAL(15,6) NOT NULL, CHANGE `sconto_unitario` `sconto_unitario` DECIMAL(15,6) NOT NULL; 
ALTER TABLE `co_scadenziario` CHANGE `da_pagare` `da_pagare` DECIMAL(15,6) NULL DEFAULT NULL, CHANGE `pagato` `pagato` DECIMAL(15,6) NULL DEFAULT NULL; 
ALTER TABLE `dt_ddt` CHANGE `rivalsainps` `rivalsainps` DECIMAL(15,6) NOT NULL, CHANGE `iva_rivalsainps` `iva_rivalsainps` DECIMAL(15,6) NOT NULL, CHANGE `ritenutaacconto` `ritenutaacconto` DECIMAL(15,6) NOT NULL, CHANGE `bollo` `bollo` DECIMAL(15,6) NOT NULL; 
ALTER TABLE `dt_righe_ddt` CHANGE `iva` `iva` DECIMAL(15,6) NOT NULL, CHANGE `iva_indetraibile` `iva_indetraibile` DECIMAL(15,6) NOT NULL, CHANGE `subtotale` `subtotale` DECIMAL(15,6) NOT NULL, CHANGE `sconto` `sconto` DECIMAL(15,6) NOT NULL, CHANGE `sconto_unitario` `sconto_unitario` DECIMAL(15,6) NOT NULL, CHANGE `provvigione` `provvigione` DECIMAL(15,6) NOT NULL, CHANGE `provvigione_unitaria` `provvigione_unitaria` DECIMAL(15,6) NOT NULL, CHANGE `provvigione_percentuale` `provvigione_percentuale` DECIMAL(15,6) NOT NULL; 
ALTER TABLE `in_fasceorarie_tipiintervento` CHANGE `costo_orario` `costo_orario` DECIMAL(15,6) NOT NULL, CHANGE `costo_km` `costo_km` DECIMAL(15,6) NOT NULL, CHANGE `costo_diritto_chiamata` `costo_diritto_chiamata` DECIMAL(15,6) NOT NULL, CHANGE `costo_orario_tecnico` `costo_orario_tecnico` DECIMAL(15,6) NOT NULL, CHANGE `costo_km_tecnico` `costo_km_tecnico` DECIMAL(15,6) NOT NULL, CHANGE `costo_diritto_chiamata_tecnico` `costo_diritto_chiamata_tecnico` DECIMAL(15,6) NOT NULL; 
ALTER TABLE `in_interventi` CHANGE `prezzo_ore_unitario` `prezzo_ore_unitario` DECIMAL(15,2) NOT NULL; 
ALTER TABLE `in_interventi_tecnici` CHANGE `prezzo_ore_unitario` `prezzo_ore_unitario` DECIMAL(15,6) NOT NULL, CHANGE `prezzo_km_unitario` `prezzo_km_unitario` DECIMAL(15,6) NOT NULL, CHANGE `prezzo_ore_consuntivo` `prezzo_ore_consuntivo` DECIMAL(15,6) NOT NULL, CHANGE `prezzo_km_consuntivo` `prezzo_km_consuntivo` DECIMAL(15,6) NOT NULL, CHANGE `prezzo_dirittochiamata` `prezzo_dirittochiamata` DECIMAL(15,6) NOT NULL, CHANGE `prezzo_ore_unitario_tecnico` `prezzo_ore_unitario_tecnico` DECIMAL(15,6) NOT NULL, CHANGE `prezzo_km_unitario_tecnico` `prezzo_km_unitario_tecnico` DECIMAL(15,6) NOT NULL, CHANGE `prezzo_ore_consuntivo_tecnico` `prezzo_ore_consuntivo_tecnico` DECIMAL(15,6) NOT NULL, CHANGE `prezzo_km_consuntivo_tecnico` `prezzo_km_consuntivo_tecnico` DECIMAL(15,6) NOT NULL, CHANGE `prezzo_dirittochiamata_tecnico` `prezzo_dirittochiamata_tecnico` DECIMAL(15,6) NOT NULL; 
ALTER TABLE `in_interventi_tecnici` CHANGE `sconto` `sconto` DECIMAL(17,8) NOT NULL, CHANGE `sconto_unitario` `sconto_unitario` DECIMAL(17,8) NOT NULL, CHANGE `scontokm` `scontokm` DECIMAL(17,8) NOT NULL, CHANGE `scontokm_unitario` `scontokm_unitario` DECIMAL(17,8) NOT NULL; 
ALTER TABLE `in_righe_interventi` CHANGE `provvigione` `provvigione` DECIMAL(15,6) NOT NULL, CHANGE `provvigione_unitaria` `provvigione_unitaria` DECIMAL(15,6) NOT NULL, CHANGE `provvigione_percentuale` `provvigione_percentuale` DECIMAL(15,6) NOT NULL, CHANGE `iva` `iva` DECIMAL(15,6) NOT NULL; 
ALTER TABLE `in_righe_interventi` CHANGE `sconto` `sconto` DECIMAL(17,8) NOT NULL, CHANGE `sconto_unitario` `sconto_unitario` DECIMAL(17,8) NOT NULL, CHANGE `sconto_iva_unitario` `sconto_iva_unitario` DECIMAL(17,8) NOT NULL, CHANGE `sconto_unitario_ivato` `sconto_unitario_ivato` DECIMAL(17,8) NOT NULL, CHANGE `sconto_percentuale` `sconto_percentuale` DECIMAL(17,8) NOT NULL; 
ALTER TABLE `in_righe_tipiinterventi` CHANGE `prezzo_acquisto` `prezzo_acquisto` DECIMAL(15,6) NOT NULL, CHANGE `prezzo_vendita` `prezzo_vendita` DECIMAL(15,6) NOT NULL, CHANGE `subtotale` `subtotale` DECIMAL(15,6) NOT NULL; 
ALTER TABLE `in_tariffe` CHANGE `costo_ore` `costo_ore` DECIMAL(15,6) NOT NULL, CHANGE `costo_km` `costo_km` DECIMAL(15,6) NOT NULL, CHANGE `costo_dirittochiamata` `costo_dirittochiamata` DECIMAL(15,6) NOT NULL, CHANGE `costo_ore_tecnico` `costo_ore_tecnico` DECIMAL(15,6) NOT NULL, CHANGE `costo_km_tecnico` `costo_km_tecnico` DECIMAL(15,6) NOT NULL, CHANGE `costo_dirittochiamata_tecnico` `costo_dirittochiamata_tecnico` DECIMAL(15,6) NOT NULL; 
ALTER TABLE `in_tipiintervento` CHANGE `costo_orario` `costo_orario` DECIMAL(15,6) NOT NULL, CHANGE `costo_km` `costo_km` DECIMAL(15,6) NOT NULL, CHANGE `costo_diritto_chiamata` `costo_diritto_chiamata` DECIMAL(15,6) NOT NULL, CHANGE `costo_orario_tecnico` `costo_orario_tecnico` DECIMAL(15,6) NOT NULL, CHANGE `costo_km_tecnico` `costo_km_tecnico` DECIMAL(15,6) NOT NULL, CHANGE `costo_diritto_chiamata_tecnico` `costo_diritto_chiamata_tecnico` DECIMAL(15,6) NOT NULL; 
ALTER TABLE `mg_articoli` CHANGE `prezzo_acquisto` `prezzo_acquisto` DECIMAL(15,6) NOT NULL, CHANGE `coefficiente` `coefficiente` DECIMAL(15,6) NOT NULL, CHANGE `prezzo_vendita` `prezzo_vendita` DECIMAL(15,6) NOT NULL; 
ALTER TABLE `or_ordini` CHANGE `rivalsainps` `rivalsainps` DECIMAL(15,6) NOT NULL, CHANGE `iva_rivalsainps` `iva_rivalsainps` DECIMAL(15,6) NOT NULL, CHANGE `ritenutaacconto` `ritenutaacconto` DECIMAL(15,6) NOT NULL; 
ALTER TABLE `or_righe_ordini` CHANGE `iva` `iva` DECIMAL(15,6) NOT NULL, CHANGE `iva_indetraibile` `iva_indetraibile` DECIMAL(15,6) NOT NULL, CHANGE `subtotale` `subtotale` DECIMAL(15,6) NOT NULL, CHANGE `sconto` `sconto` DECIMAL(15,6) NOT NULL, CHANGE `sconto_unitario` `sconto_unitario` DECIMAL(15,6) NOT NULL, CHANGE `provvigione` `provvigione` DECIMAL(15,6) NOT NULL, CHANGE `provvigione_unitaria` `provvigione_unitaria` DECIMAL(15,6) NOT NULL, CHANGE `provvigione_percentuale` `provvigione_percentuale` DECIMAL(15,6) NOT NULL;

-- Aggiunta colonna Anagrafica in Movimenti
INSERT INTO `zz_views` (`id_module`, `name`, `query`, `order`, `search`, `slow`, `format`, `html_format`, `search_inside`, `order_by`, `visible`, `summable`, `default`) VALUES
((SELECT `id` FROM `zz_modules` WHERE `name`='Movimenti'), 'Anagrafica', 'IF(`reference_type`=\"Modules\\\\Fatture\\\\Fattura\",(SELECT ragione_sociale FROM co_documenti LEFT JOIN an_anagrafiche ON co_documenti.idanagrafica=an_anagrafiche.idanagrafica WHERE co_documenti.id=mg_movimenti.reference_id),IF(`reference_type`=\"Modules\\\\DDT\\\\DDT\",(SELECT ragione_sociale FROM dt_ddt LEFT JOIN an_anagrafiche ON dt_ddt.idanagrafica=an_anagrafiche.idanagrafica WHERE dt_ddt.id=mg_movimenti.reference_id),IF(`reference_type`=\"Modules\\\\Interventi\\\\Intervento\",(SELECT ragione_sociale FROM in_interventi LEFT JOIN an_anagrafiche ON in_interventi.idanagrafica=an_anagrafiche.idanagrafica WHERE in_interventi.id=mg_movimenti.reference_id),"")))', 8, 1, 0, 0, 0, '', '', 1, 0, 0);