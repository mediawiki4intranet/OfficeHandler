<?php

class OfficeHandler extends ImageHandler
{
    public function canRender($file)
    {
        global $egOfficeHandlerMimeTypes;
        return in_array($file->mime, $egOfficeHandlerMimeTypes);
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
