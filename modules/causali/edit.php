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

?><form action="" method="post" id="edit-form">
	<input type="hidden" name="backto" value="record-edit">
	<input type="hidden" name="op" value="update">


    <div class="row">
        <div class="col-md-6">
            <div class="row">
                <div class="col-md-12">
                    {[ "type": "text", "label": "<?php echo tr('Descrizione'); ?>", "name": "descrizione", "required": 1, "value": "$descrizione$", "charcounter": 1,  "maxlength": "100" ]}
                </div>
            </div>
        </div>
    </div>
    <div class="row">
        <div class="col-md-12">
            <div class="panel panel-primary">
                <div class="panel-heading">
                    <h3 class="panel-title"><?php echo tr('Flags'); ?></h3>
                </div>
                <div class="panel-body">
                    <div class="col-md-3">
                        {[ "type": "checkbox", "label": "<?php echo tr('Causale predefinita'); ?>", "name": "predefined", "value": "$predefined$", "help":"<?php echo tr('Impostare questa causale di trasporto come predefinita per i ddt'); ?>." ]}
                    </div>
                    <div class="col-md-3">
                        {[ "type": "checkbox", "label": "<?php echo tr('Importabile?'); ?>", "name": "is_importabile", "value": "$is_importabile$", "help": "<?php echo tr('I documenti associati a questa causale possono essere importati a livello contabile in altri documenti (per esempio, in Fatture)'); ?>", "placeholder": "<?php echo tr('Importabile'); ?>" ]}
                    </div>
                    <div class="col-md-3">
                        {[ "type": "checkbox", "label": "<?php echo tr('Abilita solo note di credito'); ?>", "name": "reversed", "value": "$reversed$", "help": "<?php echo tr('I documenti associati a questa causale possono essere stornati come nota di credito'); ?>", "placeholder": "<?php echo tr('Abilita storno'); ?>" ]}
                    </div>
                    <div class="col-md-3">
                        {[ "type": "checkbox", "label": "<?php echo tr('Rientrabile?'); ?>", "name": "is_rientrabile", "value": "$is_rientrabile$", "help": "<?php echo tr('I documenti associati a questa causale possono registrare i serial degli articoli anche se già utilizzati'); ?>", "placeholder": "<?php echo tr('Rientrabile'); ?>" ]}
                    </div>
                </div>
            </div>
        </div>
    </div>

</form>

<?php
// Collegamenti diretti (numerici)
$numero_documenti = $dbo->fetchNum('SELECT id FROM dt_ddt WHERE idcausalet='.prepare($id_record).'
UNION SELECT id FROM co_documenti WHERE idcausalet='.prepare($id_record));

if (!empty($numero_documenti)) {
    echo '
<div class="alert alert-danger">
    '.tr('Ci sono _NUM_ documenti collegati', [
        '_NUM_' => $numero_documenti,
    ]).'.
</div>';
}
?>

<a class="btn btn-danger ask" data-backto="record-list">
    <i class="fa fa-trash"></i> <?php echo tr('Elimina'); ?>
</a>


<script>
    $(document).ready(function() {
        check_reversed();
    });

    $("#is_importabile").change(function() {
        check_reversed();
    });

    function check_reversed() {
        if ($("#is_importabile").is(":checked")) {
            input("reversed").enable();
        } else {
            input("reversed").disable();
            $("#reversed").prop("checked", false);
        }
    }
</script>