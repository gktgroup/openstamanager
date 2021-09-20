<?php
/*
 * OpenSTAManager: il software gestionale open source per l'assistenza tecnica e la fatturazione
 * Copyright (C) DevCode s.r.l.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 */

include_once __DIR__.'/../../core.php';

$dir = $documento->direzione;
$numero = $documento->numero_esterno ?: $documento->numero;

echo '
<form action="" method="post" id="edit-form">
	<input type="hidden" name="op" value="update">
	<input type="hidden" name="backto" value="record-edit">
	<input type="hidden" name="id_record" value="'.$id_record.'">

	<input type="hidden" name="tipo" value="'.$record['tipo'].'">
	<input type="hidden" name="descrizione" value="'.$record['descrizione'].'">
	<input type="hidden" name="iddocumento" value="'.$record['iddocumento'].'">

	<div class="panel panel-primary">
		<div class="panel-heading">
			<h3 class="panel-title">
			    '.tr('Gruppo Scadenze').'
            </h3>
		</div>

		<div class="panel-body">';

if (!empty($documento)) {
    echo '
            <div class="row">
                <div class="col-md-4">
                    <h4>'.tr('Documento').'</h4>
                    '.Modules::link($documento->getModule(), $documento->id, $documento->getReference()).'
                </div>

                <div class="col-md-4">
                    <h4>'.($documento->direzione == 'entrata' ? tr('Cliente') : tr('Fornitore')).'</h4>
                    '.Modules::link('Anagrafiche', $documento->anagrafica->id, $documento->anagrafica->ragione_sociale).'
                </div>

                <div class="col-md-4">
                    <h4>'.tr('Netto a pagare').'</h4>
                    '.moneyFormat($documento->netto).'
                </div>
            </div>

            <div class="clearfix"></div>
            <br>';
}
    echo '
            <div class="row">
                <div class="col-md-8">
                    {[ "type": "text", "label": "'.tr('Descrizione').'", "name": "descrizione", "value": "'.$gruppo['descrizione'].'" ]}
                </div>

                <div class="col-md-4">
                    {[ "type": "date", "label": "'.tr('Data di emissione').'", "name": "data_emissione", "value": "'.$gruppo['data_emissione'].'" ]}
                </div>
            </div>

            <div class="row">
                <div class="col-md-12">
                    {[ "type": "ckeditor", "label": "'.tr('Note').'", "name": "note", "value": "'.$gruppo['note'].'" ]}
                </div>
            </div>';

if ($totale_da_pagare != 0) {
    echo '
                    <div class="pull-right">
                        <a onclick="launch_modal(\''.tr('Registra contabile pagamento').'\', \''.base_path().'/add.php?id_module='.Modules::get('Prima nota')['id'].'&'.(!empty($record['iddocumento']) ? 'id_documenti='.$record['iddocumento'].'&single=1' : 'id_scadenze='.$id_record).'\');" class="btn btn-sm btn-primary">
                            <i class="fa fa-euro"></i> '.tr('Registra contabile pagamento...').'
                        </a>
                    </div>';
}

echo '
        </div>
    </div>

    <!-- Elenco scadenze -->
	<div class="box box-primary">
		<div class="box-header">
			<h3 class="box-title">'.tr('Elenco scadenza').'</h3>
            <div class="box-tools pull-right">
                <button type="button" class="btn btn-xs btn-info tip '.(empty($documento) ? 'disabled' : '').'" id="add-scadenza" '.(empty($documento) ? 'disabled' : '').' title="'.tr('È possibile aggiungere scadenze solo se è presente il collegamento a un documento, in caso contrario è consigliato creare più scadenze con la stessa descrizione').'">
                    <i class="fa fa-plus"></i> '.tr('Aggiungi scadenza').'
                </button>
            </div>
		</div>

		<div class="box-body">
            <table class="table table-hover table-condensed table-bordered">
                <thead>
                    <tr>
                        <th class="text-center" width="150">'.tr('Data').'</th>
                        <th class="text-center" width="150">'.tr('Importo').'</th>
                        <th class="text-center" width="150">'.tr('Pagato').'</th>
                        <th class="text-center" width="150">'.tr('Data concordata').'</th>
                        <th class="text-center" width="150">'.tr('Note').'</th>
                    </tr>
                </thead>

                <tbody id="scadenze">';

    foreach ($scadenze as $i => $scadenza) {
        if ($scadenza['da_pagare'] == $scadenza['pagato']) {
            $class = 'success';
        } elseif (abs($scadenza['pagato']) == 0) {
            $class = 'danger';
        } elseif (abs($scadenza['pagato']) <= abs($scadenza['da_pagare'])) {
            $class = 'warning';
        } else {
            $class = 'danger';
        }

        echo '
                    <tr class="'.$class.'">
                        <input type="hidden" name="id_scadenza['.$i.']" value="'.$scadenza['id'].'">

                        <td class="text-center">
                            {[ "type": "date", "name": "scadenza['.$i.']", "value": "'.$scadenza['scadenza'].'" ]}
                        </td>

                        <td class="text-right">
                            {[ "type": "number", "name": "da_pagare['.$i.']", "decimals": 2, "value": "'.numberFormat($scadenza['da_pagare'], 2).'", "onchange": "controlloTotale()" ]}
                        </td>

                        <td class="text-right">
                            {[ "type": "number", "name": "pagato['.$i.']", "decimals": 2, "value": "'.numberFormat($scadenza['pagato']).'"  ]}
                        </td>

                        <td class="text-center">
                            {[ "type": "date", "name": "data_concordata['.$i.']", "value": "'.$scadenza['data_concordata'].'" ]}
                        </td>

                        <td>
                            {[ "type": "textarea", "name": "note['.$i.']", "value": "'.$scadenza['note'].'" ]}
                        </td>
                    </tr>';
    }

    echo '
                </tbody>
                <tfoot>
                    <tr>
                        <td class="text-right"><b>'.tr('Totale').'</b></td>
                        <td class="text-right" id="totale_utente">'.numberFormat($totale_da_pagare).'</td>
                        <td class="text-right"></td>
                        <td class="text-right"></td>
                    </tr>
                </tfoot>
            </table>

            <div class="alert alert-warning hide" id="totale">'.tr('Il totale da pagare non corrisponde con il totale della fattura che è pari a _MONEY_', [
                '_MONEY_' => '<b>'.moneyFormat($totale_da_pagare).'</b>',
            ]); ?>.<br><?php echo tr('Differenza di _TOT_ _CURRENCY_', [
                    '_TOT_' => '<span id="diff"></span>',
                    '_CURRENCY_' => currency(),
                ]).'.
            </div>

            <input type="hidden" id="totale_da_pagare" value="'.round($totale_da_pagare, 2).'">
		</div>
	</div>
</form>';

$id_scadenza = $id_record;

// Forzatura per allegare file sempre al primo record
if (!empty($documento)) {
    $id_scadenza = $dbo->fetchOne('SELECT id FROM co_scadenze WHERE iddocumento='.prepare($documento->id).' ORDER BY id')['id'];
}
?>

{( "name": "filelist_and_upload", "id_module": "$id_module$", "id_record": "<?php echo $id_scadenza; ?>" )}

{( "name": "log_email", "id_module": "$id_module$", "id_record": "$id_record$" )}

<?php
if (empty($documento)) {
    echo '
<a class="btn btn-danger ask" data-backto="record-list">
    <i class="fa fa-trash"></i> '.tr('Elimina').'
</a>';
}

echo '
<table class="hide">
    <tbody id="scadenza-template">
        <tr class="danger">
            <input type="hidden" name="id_scadenza[-id-]" value="">

            <td class="text-center">
                {[ "type": "date", "name": "scadenza[-id-]" ]}
            </td>

            <td class="text-right">
                {[ "type": "number", "name": "da_pagare[-id-]", "decimals": 2, "onchange": "controlloTotale()" ]}
            </td>

            <td class="text-right">
                {[ "type": "number", "name": "pagato[-id-]", "decimals": 2 ]}
            </td>

            <td class="text-center">
                {[ "type": "date", "name": "data_concordata[-id-]" ]}
            </td>

            <td>
                {[ "type": "textarea", "name": "note[-id-]" ]}
            </td>
        </tr>
    </tbody>
</table>

<script>
    var i = '.$i.';
	$(document).on("click", "#add-scadenza", function() {
        cleanup_inputs();

        i++;
		var text = replaceAll($("#scadenza-template").html(), "-id-", "" + i);

		$("#scadenze").append(text);
		restart_inputs();
	});
</script>';

// Abilitazione dei controlli solo per Scadenze collegate a documenti
if (!empty($documento)) {
    echo '
<script>
    globals.cifre_decimali = 2;

	$(document).ready(function() {
        controlloTotale();';

    if ($dir == 'uscita') {
        echo '
        $("#email-button").remove();';
    }
    echo '
	});

    function controlloTotale() {
        let totale_da_pagare = parseFloat($("#totale_da_pagare").val());
        let totale_utente = 0;

        $("input[name*=da_pagare]").each(function() {
            totale_utente += input(this).get();
        });

        if (isNaN(totale_utente)) {
            totale_utente = 0;
        }

        totale_utente = Math.round(totale_utente * 100) / 100;
        totale_da_pagare = Math.round(totale_da_pagare * 100) / 100;

        let diff = Math.abs(totale_da_pagare) - Math.abs(totale_utente);

        if (diff == 0) {
            $("#totale").addClass("hide");
        } else {
            $("#totale").removeClass("hide");
        }

        $("#diff").html(diff.toLocale());
        $("#totale_utente").html(totale_utente.toLocale());
    }
</script>';
}
