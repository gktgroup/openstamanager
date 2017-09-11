<?php

include_once __DIR__.'/../../core.php';

include_once $docroot.'/modules/articoli/modutil.php';

$query = 'SELECT *, (SELECT codice FROM mg_articoli WHERE id=mg_articoli_interventi.idarticolo) AS codice, mg_articoli_interventi.id AS idriga, (SELECT prc_guadagno FROM mg_listini WHERE id=(SELECT idlistino_vendite FROM an_anagrafiche WHERE idanagrafica=(SELECT idanagrafica FROM in_interventi WHERE id=mg_articoli_interventi.idintervento) ) ) AS prc_guadagno FROM mg_articoli_interventi WHERE idintervento='.prepare($id_record).' '.Modules::getAdditionalsQuery('Magazzino');
$rs = $dbo->fetchArray($query);

if (!empty($rs)) {
    echo '
<table class="table table-striped table-condensed table-hover table-bordered">
    <tr>
        <th>'.tr('Articolo').'</th>
        <th width="8%">'.tr('Q.tà').'</th>';

    if (Auth::admin() || $_SESSION['gruppo'] != 'Tecnici') {
        echo '
        <th width="15%">'.tr('Prezzo di acquisto').'</th>';
    }

    if (Auth::admin() || $_SESSION['gruppo'] != 'Tecnici') {
        echo '
        <th width="15%">'.tr('Prezzo di vendita').'</th>
        <th width="15%">'.tr('Subtotale').'</th>';
    }

    if ($rs[0]['stato'] != 'Fatturato' && $rs[0]['stato'] != 'Completato') {
        echo '
        <th width="80"></th>';
    }
    echo '
    </tr>';

    foreach ($rs as $r) {
        // Individuazione dei seriali
        if (!empty($r['idarticolo']) && !empty($r['abilita_serial'])) {
            $serials = array_column($dbo->fetchArray('SELECT serial FROM mg_prodotti WHERE serial IS NOT NULL AND id_riga_intervento='.prepare($r['id'])), 'serial');
            $mancanti = $r['qta'] - count($serials);

            if ($mancanti > 0) {
                $extra = 'class="warning"';
            } else {
                $mancanti = 0;
            }
        }

        echo '
    <tr '.$extra.'>
        <td>
            <input type="hidden" name="id" value="'.$r['id'].'">
            '.Modules::link('Articoli', $r['idarticolo'], $r['descrizione']);

        // Info extra (lotto, serial, altro)
        if (!empty($r['abilita_serial'])) {
            if (!empty($mancanti)) {
                echo '
            <br><b><small class="text-danger">'.tr('_NUM_ serial mancanti', [
                '_NUM_' => $mancanti,
            ]).'</small></b>';
            }
            if (!empty($serials)) {
                echo '
            <br>'.tr('SN').': '.implode(', ', $serials);
            }
        }

        echo '
        </td>';

        // Quantità
        echo '
        <td class="text-right">
            '.Translator::numberToLocale($r['qta']).' '.$r['um'].'
        </td>';

        if (Auth::admin() || $_SESSION['gruppo'] != 'Tecnici') {
            echo '
        <td class="text-right">
            '.Translator::numberToLocale($r['prezzo_acquisto']).' &euro;
        </td>';
        }

        if (Auth::admin() || $_SESSION['gruppo'] != 'Tecnici') {
            // Prezzo unitario
            echo '
        <td class="text-right">
            '.Translator::numberToLocale($r['prezzo_vendita']).' &euro;';

            if ($r['sconto_unitario'] > 0) {
                echo '
            <br><span class="label label-danger">
                - sconto '.Translator::numberToLocale($r['sconto_unitario']).($r['tipo_sconto'] == 'PRC' ? '%' : ' &euro;').'
            </span>';
            }

            echo '
        </td>';

            // Prezzo di vendita
            echo '
        <td class="text-right">
            <span class="prezzo_articolo">'.Translator::numberToLocale(sum($r['prezzo_vendita'] * $r['qta'], -$r['sconto'])).'</span> &euro;
        </td>';
        }

        // Pulsante per riportare nel magazzino centrale.
        // Visibile solo se l'intervento non è stato nè fatturato nè completato.
        if ($rs[0]['stato'] != 'Fatturato' && $rs[0]['stato'] != 'Completato') {
            echo '
        <td>';

            if ($r['abilita_serial']) {
                echo '
            <button type="button" class="btn btn-info btn-xs" data-toggle="tooltip" onclick="launch_modal(\''.tr('Modifica articoli').'\', \''.$rootdir.'/modules/fatture/add_serial.php?id_module='.$id_module.'&id_record='.$id_record.'&idarticolo='.$r['idriga'].'&idriga='.$r['id'].'\', 1);"><i class="fa fa-barcode"></i></button>';
            }

            echo '

            <button type="button" class="btn btn-warning btn-xs" data-toggle="tooltip" onclick="launch_modal(\''.tr('Modifica articoli').'\', \''.$rootdir.'/modules/interventi/add_articolo.php?id_module='.$id_module.'&id_record='.$id_record.'&idriga='.$r['idriga'].'\', 1);"><i class="fa fa-edit"></i></button>

            <button type="button" class="btn btn-danger btn-xs" data-toggle="tooltip" title="Riporta in magazzino" onclick="if(confirm(\''.tr('Riportare questo articolo in magazzino?').'\') ){ ritorna_al_magazzino(\''.$r['id'].'\'); }"><i class="fa fa-angle-double-left"></i> <i class="fa fa-truck"></i></button>
        </td>';
        }
        echo '
    </tr>';
    }

    echo '
</table>';
}
?>
<script type="text/javascript">
    function ritorna_al_magazzino( id ){
        $.post(globals.rootdir + '/modules/interventi/actions.php', {op: 'unlink_articolo', idriga: id, id_record: '<?php echo $id_record ?>', id_module: '<?php echo $id_module ?>' }, function(data, result){
            if( result == 'success' ){
                // ricarico l'elenco degli articoli
                $('#articoli').load(globals.rootdir + '/modules/interventi/ajax_articoli.php?id_module=<?php echo $id_module ?>&id_record=<?php echo $id_record ?>');

                $('#costi').load(globals.rootdir + '/modules/interventi/ajax_costi.php?id_module=<?php echo $id_module ?>&id_record=<?php echo $id_record ?>');
            }
        });
    }
</script>
