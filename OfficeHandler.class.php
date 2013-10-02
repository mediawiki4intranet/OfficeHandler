<?php

class OfficeHandler extends ImageHandler
{
    public static $mimes = array(
        'application/vnd.ms-excel',
        'application/msword',
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
    );

    public function canRender($file)
    {
        return in_array($file->mime, static::$mimes);
    }

    public function doTransform($image, $dstPath, $dstUrl, $params, $flags = 0)
    {
        if (isset($params['imagehistory']) && $params['imagehistory'])
        {
            return false;
        }
        return new OfficeTransformOutput($image, $dstUrl, $params, $dstPath);
    }

    public function getThumbType($ext, $mime, $params = null) {
        return null;
    }
}

class OfficeTransformOutput extends MediaTransformOutput
{
    const CACHE_PATH = '/generated/office/';
    const DEBUG = false;
    const SCRIPT_PROD = 'libreoffice --convert-to html %1$s --invisible';
    const SCRIPT_DEV  = '/opt/libreoffice/opt/libreoffice4.1/program/soffice --convert-to html %1$s --invisible';

    protected $script = self::SCRIPT_PROD;

    public function __construct($file, $url, $params, $path)
    {
        global $wgUploadDirectory;
        $this->file   = $file;
        $this->url    = $url;
        $this->params = $params;
        $this->path   = $path;
        // real path of file
        $this->realPath   = $this->file->repo->directory . '/' . $this->file->hashPath . $this->file->name;
        // generated name without extension (with revId)
        $this->generatedName = $this->file->name . '.' . $this->file->title->getLatestRevID();
        // directory to generated path
        $this->generatedDirectory = $wgUploadDirectory . static::CACHE_PATH . $this->file->hashPath;
        // full generated path
        $this->generatedPath = $this->generatedDirectory . $this->generatedName . '.html';
        // file is already generated
        $this->isGenerated = file_exists($this->generatedPath);

        if (self::DEBUG)
        {
            $this->script = self::SCRIPT_DEV;
        }
        $this->script = sprintf($this->script, $this->realPath);
    }

    public function toHtml($options = array())
    {
        if (isset($options['file-link']) && $options['file-link'])
        {
            if ($this->isGenerated)
            {
                global $wgServer, $wgScriptPath;
                $docRoot = dirname(dirname(__DIR__));
                $url = $wgServer . $wgScriptPath . mb_substr($this->generatedPath, mb_strlen($docRoot));
                return sprintf('<iframe src="%1$s" width="100%%" height="300"></iframe>', $url);
            }
            else
            {
                $html = '<a href="' . $this->file->title->getFullURL() . '" id="office-generate-preview">' . wfMsg('generate') . '</a>';
                return $html;
            }
        }
        elseif (isset($options['desc-link']) && $options['desc-link'])
        {
            // if other pages thumb is not avaliable
            global $wgUser;
            return $wgUser->getSkin()->link($this->file->title, $this->file->title->getPrefixedText());
        }
        return wfMsg('not-exist');
    }

    // Generation html "cache"
    public function generate()
    {
        global $wgTmpDirectory;

        // Convertation of project's file to xml
        if (!file_exists($wgTmpDirectory))
        {
            mkdir($wgTmpDirectory, 0775, true);
        }
        $name = $this->file->name;
        $name = mb_substr($name, 0, mb_strrpos($name, "."));
        $tmpName = $wgTmpDirectory . '/' . $name . '.html';
        $curDir = getcwd();
        chdir($wgTmpDirectory);
        exec($this->script);
        chdir($curDir);
        if (!file_exists($tmpName))
        {
            return false;
        }

        $content = file_get_contents($tmpName);
        unlink($tmpName);
        foreach (scandir($wgTmpDirectory) as $file)
        {
            if (strpos($file, 'core.') === 0)
            {
                unlink($wgTmpDirectory . '/' . $file);
            }
        }

        // unlink old versions of html
        if (!file_exists($this->generatedDirectory))
        {
            mkdir($this->generatedDirectory, 0775, true);
        }
        foreach (scandir($this->generatedDirectory) as $file)
        {
            if (stripos($file, $this->file->name) === 0)
            {
                unlink ($this->generatedDirectory . '/' . $file);
            }
        }

        if (!file_exists(dirname($this->generatedPath)))
        {
            @mkdir(dirname($this->generatedPath), 0775, true);
        }
        file_put_contents($this->generatedPath, $content);
        if (!file_exists($this->generatedPath))
        {
            return false;
        }
        $this->isGenerated = true;
        return true;
    }
}
