<?php

include_once __DIR__.'/../../core.php';

// Mostro le righe del preventivo
$totale_preventivo = 0.00;
$totale_imponibile = 0.00;
$totale_iva = 0.00;
$totale_da_evadere = 0.00;

/*
ARTICOLI
*/
$rs_art = $dbo->fetchArray('SELECT * FROM co_righe2_contratti WHERE idcontratto='.prepare($id_record).' ORDER BY `order`');
$imponibile_art = 0.0;
$iva_art = 0.0;

echo '
<table class="table table-striped table-hover table-condensed">
    <thead>
        <tr>
            <th>'.tr('Descrizione').'</th>
            <th width="10%" class="text-center">'.tr('Q.tà').'</th>
            <th width="10%" class="text-center">'.tr('U.m.').'</th>
            <th width="12%" class="text-center">'.tr('Costo unitario').'</th>
            <th width="12%" class="text-center">'.tr('Iva').'</th>
            <th width="10%" class="text-center">'.tr('Imponibile').'</th>
            <th width="80"></th>
        </tr>
    </thead>
    <tbody class="sortable">';

// se ho almeno un articolo caricato mostro la riga
if (!empty($rs_art)) {
    foreach ($rs_art as $r) {
        // descrizione
        echo '
        <tr data-id="'.$r['id'].'">
            <td>
            '.nl2br($r['descrizione']).'
            </td>';

        // q.tà
        echo '
            <td class="text-center">
                '.Translator::numberToLocale($r['qta']).'
            </td>';

        // um
        echo '
            <td class="text-center">
                '.$r['um'].'
            </td>';

        // costo unitario
        echo '
            <td class="text-center">
                '.Translator::numberToLocale($r['subtotale'] / $r['qta']).' &euro;
            </td>';

        // iva
        echo '
            <td class="text-right">
                '.Translator::numberToLocale($r['iva'])." &euro;<br>
                <small class='help-block'>".$r['desc_iva'].'</small>
            </td>';

        // Imponibile
        echo '
            <td class="text-right">
                '.Translator::numberToLocale($r['subtotale']).' &euro;';

        if ($r['sconto_unitario'] > 0) {
            echo '
                <br><small class="label label-danger">- '.tr('sconto _TOT_ _TYPE_', [
                    '_TOT_' => Translator::numberToLocale($r['sconto_unitario']),
                    '_TYPE_' => ($r['tipo_sconto'] == 'PRC' ? '%' : '&euro;'),
                ]).'</small>';
        }

        echo '
            </td>';

        // Possibilità di rimuovere una riga solo se il preventivo non è stato pagato
        echo '
            <td class="text-center">';

        if ($records[0]['stato'] != 'Pagato' && empty($r['sconto_globale'])) {
            echo '
                <form action="'.$rootdir.'/editor.php?id_module='.Modules::get('Contratti')['id'].'&id_record='.$id_record.'" method="post" id="delete-form-'.$r['id'].'" role="form">
                    <input type="hidden" name="backto" value="record-edit">
                    <input type="hidden" name="id_record" value="'.$id_record.'">
                    <input type="hidden" name="op" value="delriga">
                    <input type="hidden" name="idriga" value="'.$r['id'].'">
                    <input type="hidden" name="idarticolo" value="'.$r['idarticolo'].'">

                    <div class="btn-group">';
            echo "
                        <a class='btn btn-xs btn-warning' onclick=\"launch_modal('Modifica riga', '".$rootdir.'/modules/contratti/add_riga.php?idcontratto='.$id_record.'&idriga='.$r['id']."', 1 );\"><i class='fa fa-edit'></i></a>
                        <a href='javascript:;' class='btn btn-xs btn-danger' title='Rimuovi questa riga' onclick=\"if( confirm('Rimuovere questa riga dal contratto?') ){ $('#delete-form-".$r['id']."').submit(); }\"><i class='fa fa-trash'></i></a>";
            echo '
                    </div>
                </form>';
        }

        if (empty($r['sconto_globale'])) {
            echo '
                <div class="handle clickable" style="padding:10px">
                    <i class="fa fa-sort"></i>
                </div>';
        }

        echo '
            </td>
        </tr>';

        $iva_art += $r['iva'];
        $imponibile_art += $r['subtotale'] - $r['sconto'];
        $imponibile_nosconto += $r['subtotale'];
        $sconto_art += $r['sconto'];
    }
}

echo '
    </tbody>';

// SCONTO
if (abs($sconto_art) > 0) {
    // Totale imponibile scontato
    echo '
    <tr>
        <td colspan="5"" class="text-right">
            <b>'.tr('Imponibile', [], ['upper' => true]).':</b>
        </td>
        <td class="text-right">
            <span id="budget">'.Translator::numberToLocale($imponibile_nosconto).' &euro;</span>
        </td>
        <td></td>
    </tr>';

    echo '
    <tr>
        <td colspan="5"" class="text-right">
            <b>'.tr('Sconto', [], ['upper' => true]).':</b>
        </td>
        <td class="text-right">
            '.Translator::numberToLocale($sconto_art).' &euro;
        </td>
        <td></td>
    </tr>';

    // Totale imponibile scontato
    echo '
    <tr>
        <td colspan="5"" class="text-right">
            <b>'.tr('Imponibile scontato', [], ['upper' => true]).':</b>
        </td>
        <td class="text-right">
            '.Translator::numberToLocale($imponibile_art).' &euro;
        </td>
        <td></td>
    </tr>';
} else {
    // Totale imponibile
    echo '
    <tr>
        <td colspan="5"" class="text-right">
            <b>'.tr('Imponibile', [], ['upper' => true]).':</b>
        </td>
        <td class="text-right">
            <span id="budget">'.Translator::numberToLocale($imponibile_art).' &euro;</span>
        </td>
        <td></td>
    </tr>';
}

// Totale iva
echo '
    <tr>
        <td colspan="5"" class="text-right">
            <b>'.tr('Iva', [], ['upper' => true]).':</b>
        </td>
        <td class="text-right">
            '.Translator::numberToLocale($iva_art).' &euro;
        </td>
        <td></td>
    </tr>';

// Totale contratto
echo '
    <tr>
        <td colspan="5"" class="text-right">
            <b>'.tr('Totale', [], ['upper' => true]).':</b>
        </td>
        <td class="text-right">
            '.Translator::numberToLocale($imponibile_art + $iva_art).' &euro;
        </td>
        <td></td>
    </tr>';

echo '
</table>';

echo '
<script>
$(document).ready(function(){
	$(".sortable").each(function() {
        $(this).sortable({
            axis: "y",
            handle: ".handle",
			cursor: "move",
			dropOnEmpty: true,
			scroll: true,
			start: function(event, ui) {
				ui.item.data("start", ui.item.index());
			},
			update: function(event, ui) {
				$.post("'.$rootdir.'/actions.php", {
					id: ui.item.data("id"),
					id_module: '.$id_module.',
					id_record: '.$id_record.',
					op: "update_position",
					start: ui.item.data("start"),
					end: ui.item.index()
				});
			}
		});
	});
});
</script>';
