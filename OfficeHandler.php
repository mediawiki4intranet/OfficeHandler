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
$wgAjaxExportList[] = 'OfficeAjax::generatePreview';

$wgExtensionCredits['parserhook'][] = array(
	'name'    => 'MS Project file page',
	'author'  => 'Vladimir Koptev',
	'url'     => 'http://wiki.4intra.net/OfficeHandler',
	'version' => '2013-08-30',
);
foreach (OfficeHandler::$mimes as $mime)
{
    $wgMediaHandlers[$mime] = 'OfficeHandler';
}

$wgResourceModules['OfficeHandler'] = array(
	'scripts'       => array('Office.js'),
	'styles'        => array(),
	'dependencies'  => array('jquery'),
	'localBasePath' => __DIR__,
	'remoteExtPath' => 'OfficeHandler',
	'messages' => array(
		'loading'
	),
);
$wgHooks['BeforePageDisplay'][] = 'efOfficeBeforePageDisplay';

function efOfficeBeforePageDisplay(&$output, &$skin)
{
    $output->addModules( 'OfficeHandler' );
    return true;
}
