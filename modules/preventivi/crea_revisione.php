<?php
/*
 * OpenSTAManager: il software gestionale open source per l'assistenza tecnica e la fatturazione
 * Copyright (C) DevCode s.n.c.
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

use Modules\Preventivi\Preventivo;

$revisione = Preventivo::find($id_record)->ultima_revisione;
?>

<form action="" method="post">
	<input type="hidden" name="backto" value="record-edit">
	<input type="hidden" name="op" value="add_revision">

    <div class="row">
        <div class="col-md-12">
            {[ "type": "text", "label": "<?php echo tr('Descrizione'); ?>", "name": "descrizione", "value": "Revisione n. <?php echo $revisione + 1; ?>" ]}
        </div>
    </div>

    <div class="row">
		<div class="col-md-12 text-right">
			<button type="submit" class="btn btn-primary">
			    <i class="fa fa-plus"></i><?php echo tr(' Aggiungi'); ?>
            </button>
		</div>
	</div>
</form>