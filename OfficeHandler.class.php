<?php

class OfficeHandler extends ImageHandler
{
    const MIME = 'application/x-msproject';

    protected $isMpp = false;
    protected $MSProjectHandler = null;

    protected function checkIsMpp(&$file)
    {
        $ext = substr($file->name, strripos($file->name, '.') + 1);
        $mm = MimeMagic::singleton();
        if (isset($mm->mExtToMime[$ext]) &&
            strpos($mm->mExtToMime[$ext], self::MIME) !== false &&
            ($file->mime === self::MIME || $file->mime === 'application/msword'))
        {
            $file->mime = self::MIME;
            return true;
        }
        return false;
    }

    public function canRender($file)
    {
        if ($this->checkIsMpp($file))
        {
            return true;
        }
        global $egOfficeHandlerMimeTypes;
        return in_array($file->mime, $egOfficeHandlerMimeTypes);
    }

    public function doTransform($image, $dstPath, $dstUrl, $params, $flags = 0)
    {
        if (isset($params['imagehistory']) && $params['imagehistory'])
        {
            return false;
        }
        if ($this->checkIsMpp($image))
        {
            return new MSProjectTransformOutput($image, $dstUrl, $params, $dstPath);
        }
        return new OfficeTransformOutput($image, $dstUrl, $params, $dstPath);
    }

    public function getThumbType($ext, $mime, $params = null) {
        return null;
    }
}
