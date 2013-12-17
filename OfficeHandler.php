<?php

/**
 * OfficeHandler extension
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 * http://www.gnu.org/copyleft/gpl.html
 *
 * @package MediaWiki
 * @subpackage Extensions
 * @author Vitaliy Filippov <vitalif@mail.ru>, 2009+
 * @license GNU General Public License 2.0 or later
 * @link http://wiki.4intra.net/PopupWhatlinkshere
 */

if (!defined('MEDIAWIKI'))
{
    echo "This file is an extension to the MediaWiki software and cannot be used standalone.\n";
    die();
}

$wgExtensionMessagesFiles['OfficeHandler'] = dirname(__FILE__).'/OfficeHandler.i18n.php';
$wgAutoloadClasses['OfficeHandler'] = dirname(__FILE__).'/OfficeHandler.class.php';
$wgAutoloadClasses['OfficeAjax'] = dirname(__FILE__).'/OfficeAjax.class.php';
$wgAutoloadClasses['MSProjectTransformOutput'] = dirname(__FILE__).'/MSProjectTransformOutput.php';
$wgAutoloadClasses['OfficeTransformOutput'] = dirname(__FILE__).'/OfficeTransformOutput.php';
$wgAjaxExportList[] = 'OfficeAjax::generatePreview';

$wgExtensionCredits['parserhook'][] = array(
    'name'    => 'Office document media handler and preview via LibreOffice',
    'author'  => 'Vladimir Koptev',
    'url'     => 'http://wiki.4intra.net/OfficeHandler',
    'version' => '2013-08-30',
);

$wgResourceModules['OfficeHandler'] = array(
    'scripts'       => array('Office.js', 'xslt/msp-outline.js'),
	'styles'        => array('xslt/msp-outline.css'),
    'localBasePath' => __DIR__,
    'remoteExtPath' => 'OfficeHandler',
    'messages'      => array('loading'),
);
$wgMediaHandlers[OfficeHandler::MIME] = 'OfficeHandler';
$wgHooks['BeforePageDisplay'][] = 'efOfficeBeforePageDisplay';

function efOfficeBeforePageDisplay(&$output, &$skin)
{
    $output->addModules('OfficeHandler');
    return true;
}

$egOfficeHandlerMimeTypes = array(
    'application/vnd.ms-excel',
    'application/msword',
    'application/msproject',
    'application/vnd.oasis.opendocument.tex',
    'application/vnd.oasis.opendocument.text-template',
    'application/vnd.oasis.opendocument.graphics',
    'application/vnd.oasis.opendocument.text',
    'application/vnd.oasis.opendocument.text-template',
    'application/vnd.oasis.opendocument.graphics',
    'application/vnd.oasis.opendocument.graphics-template',
    'application/vnd.oasis.opendocument.presentation',
    'application/vnd.oasis.opendocument.presentation-template',
    'application/vnd.oasis.opendocument.spreadsheet',
    'application/vnd.oasis.opendocument.spreadsheet-template',
    'application/vnd.oasis.opendocument.chart',
    'application/vnd.oasis.opendocument.chart-template',
    'application/vnd.oasis.opendocument.image',
    'application/vnd.oasis.opendocument.image-template',
    'application/vnd.oasis.opendocument.formula',
    'application/vnd.oasis.opendocument.formula-template',
    'application/vnd.oasis.opendocument.text-master',
    'application/vnd.oasis.opendocument.text-web',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.template',
    'application/vnd.ms-word.document.macroEnabled.12',
    'application/vnd.ms-word.template.macroEnabled.12',
    'application/vnd.openxmlformats-officedocument.presentationml.template',
    'application/vnd.openxmlformats-officedocument.presentationml.slideshow',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    'application/vnd.ms-powerpoint.addin.macroEnabled.12',
    'application/vnd.ms-powerpoint.presentation.macroEnabled.12',
    'application/vnd.ms-powerpoint.presentation.macroEnabled.12',
    'application/vnd.ms-powerpoint.slideshow.macroEnabled.12',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.template',
    'application/vnd.ms-excel.sheet.macroEnabled.12',
    'application/vnd.ms-excel.template.macroEnabled.12',
    'application/vnd.ms-excel.addin.macroEnabled.12',
    'application/vnd.ms-excel.sheet.binary.macroEnabled.12',
    'application/vnd.ms-xpsdocument',
    'application/x-opc+zip',
    'application/x-msproject',
);

foreach ($egOfficeHandlerMimeTypes as $mime)
{
    $wgMediaHandlers[$mime] = 'OfficeHandler';
}
