import 'package:html_character_entities/html_character_entities.dart';

class TextMixin {
  String serverSafe(String str) {
    return HtmlCharacterEntities.encode(str,
        characters:
            '¿¡&ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿ');
  }

  static String fixString(String str) {
    if (str == null) return null;
    return HtmlCharacterEntities.decode(str);
    /*
    return str
        .replaceAll('&amp;', '&')
        .replaceAll('&Ntilde;', 'Ñ')
        .replaceAll('&ntilde;', 'ñ')
        .replaceAll('&Ntilde;', 'Ñ')
        .replaceAll('&Agrave;', 'À')
        .replaceAll('&Aacute;', 'Á')
        .replaceAll('&Acirc;', 'Â')
        .replaceAll('&Atilde;', 'Ã')
        .replaceAll('&Auml;', 'Ä')
        .replaceAll('&Aring;', 'Å')
        .replaceAll('&AElig;', 'Æ')
        .replaceAll('&Ccedil;', 'Ç')
        .replaceAll('&Egrave;', 'È')
        .replaceAll('&Eacute;', 'É')
        .replaceAll('&Ecirc;', 'Ê')
        .replaceAll('&Euml;', 'Ë')
        .replaceAll('&Igrave;', 'Ì')
        .replaceAll('&Iacute;', 'Í')
        .replaceAll('&Icirc;', 'Î')
        .replaceAll('&Iuml;', 'Ï')
        .replaceAll('&ETH;', 'Ð')
        .replaceAll('&Ntilde;', 'Ñ')
        .replaceAll('&Ograve;', 'Ò')
        .replaceAll('&Oacute;', 'Ó')
        .replaceAll('&Ocirc;', 'Ô')
        .replaceAll('&Otilde;', 'Õ')
        .replaceAll('&Ouml;', 'Ö')
        .replaceAll('&Oslash;', 'Ø')
        .replaceAll('&Ugrave;', 'Ù')
        .replaceAll('&Uacute;', 'Ú')
        .replaceAll('&Ucirc;', 'Û')
        .replaceAll('&Uuml;', 'Ü')
        .replaceAll('&Yacute;', 'Ý')
        .replaceAll('&THORN;', 'Þ')
        .replaceAll('&szlig;', 'ß')
        .replaceAll('&agrave;', 'à')
        .replaceAll('&aacute;', 'á')
        .replaceAll('&acirc;', 'â')
        .replaceAll('&atilde;', 'ã')
        .replaceAll('&auml;', 'ä')
        .replaceAll('&aring;', 'å')
        .replaceAll('&aelig;', 'æ')
        .replaceAll('&ccedil;', 'ç')
        .replaceAll('&egrave;', 'è')
        .replaceAll('&eacute;', 'é')
        .replaceAll('&ecirc;', 'ê')
        .replaceAll('&euml;', 'ë')
        .replaceAll('&igrave;', 'ì')
        .replaceAll('&iacute;', 'í')
        .replaceAll('&icirc;', 'î')
        .replaceAll('&iuml;', 'ï')
        .replaceAll('&eth;', 'ð')
        .replaceAll('&ntilde;', 'ñ')
        .replaceAll('&ograve;', 'ò')
        .replaceAll('&oacute;', 'ó')
        .replaceAll('&ocirc;', 'ô')
        .replaceAll('&otilde;', 'õ')
        .replaceAll('&ouml;', 'ö')
        .replaceAll('&oslash;', 'ø')
        .replaceAll('&ugrave;', 'ù')
        .replaceAll('&uacute;', 'ú')
        .replaceAll('&ucirc;', 'û')
        .replaceAll('&uuml;', 'ü')
        .replaceAll('&yacute;', 'ý')
        .replaceAll('&thorn;', 'þ')
        .replaceAll('&yuml;', 'ÿ');
        */
  }
}
