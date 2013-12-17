<?php

class MSProjectTransformOutput extends MediaTransformOutput
{
    const CACHE_PATH = '/generated/office/';
    const PROJECTLIBRE_SCRIPT = './projectlibre.sh';
    const PROJECTLIBRE_DIR = 'projectlibre';
    const XSLT = '/xslt/msp-gantt-ru.xsl';
    
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
    }
    
    public function toHtml($options = array())
    {
        if (isset($options['file-link']) && $options['file-link'])
        {
            // if file page
            $show = true;
            if (!$this->isGenerated)
            {
                $show = $this->generate();
            }
            return $show ? file_get_contents($this->generatedPath) : wfMsg('not-exist');
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
    protected function generate()
    {
        global $wgTmpDirectory;
        
        // Convertation of project's file to xml
        if (!file_exists($wgTmpDirectory))
        {
            mkdir($wgTmpDirectory, 0775, true);
        }
        $xmlName = $wgTmpDirectory . '/' . $this->generatedName . '.xml';
        $curDir = getcwd();
        chdir(__DIR__ . '/' . static::PROJECTLIBRE_DIR);
        exec(static::PROJECTLIBRE_SCRIPT . ' ' . $this->realPath . ' ' . $xmlName, $out, $return);
        chdir($curDir);
        if (!file_exists($xmlName))
        {
            return false;
        }
        
        // make XSLT convertion
        $xml = new DOMDocument();
        $xml->load($xmlName);

        $xsl = new DOMDocument();
        $xsl->load( __DIR__ . static::XSLT);
        
        $proc = new XSLTProcessor();
        $proc->importStylesheet($xsl);
        $html = $proc->transformToXml($xml);
        $html = substr($html, stripos($html, '<table'));
        $html = substr($html, 0, stripos($html, '</table>') + strlen('</table>'));
        // HACK! global js-variable
        $html .= '<script type="text/javascript">msp = {};</script>';
        
        // unlink tmp file
        unlink($xmlName);
        
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
        file_put_contents($this->generatedPath, $html);
        if (!file_exists($this->generatedPath))
        {
            return false;
        }
        return true;
    }
}
