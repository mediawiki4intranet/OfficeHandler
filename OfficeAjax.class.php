<?php

class OfficeAjax
{
    public static function generatePreview($pagename)
    {
        $result = array();

        $title = Title::newFromText($pagename);
        $file = wfFindFile($title);
        $transform = $file->transform(array(
            'width' => 0
        ));
        if ($code = $transform->generate())
        {
            $result['html'] = $transform->toHtml(array('file-link' => true));
        }
        else
        {
            $result['html'] = wfMsg('not-exist');
            $result['code'] = $code;
        }

        return json_encode($result);
    }
}
