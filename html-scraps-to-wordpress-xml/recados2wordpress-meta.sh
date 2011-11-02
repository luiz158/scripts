#!/bin/bash
# 2010-11-04 http://aurelio.net
#
# Uso: cat arquivo.html | ./recados2wordpress.sh | ./insert-id.py | ./unique-timestamp.py > arquivo.xml
#
# Converte os comentários do script http://aurelio.net/bin/php/scraps.phps
# para o formato do WordPress (WXR).
#
# É necessário ainda passar o XML resultante pelo insert-id.py, para que cada
# comentário ganhe um número ID próprio na tag <wp:comment_id>. Isso é
# necessário para que o WordPress inclua todos os comentários, senão ele irá
# incluir somente o último. Será atribuído um novo ID automaticamente durante
# a importação. Porém, é importante que a ordem dos comentários seja mantida.
# Então, se os comentários mais recentes aparecem primeiro, ligue a variável
# 'reverse' no insert-id.py.
#
# É também necessário passar o XML pelo unique-timestamp.py, para garantir
# uma data/hora exclusiva para cada comentário. Como o script PHP original
# dos recados guardava apenas o dia e não a hora, todos os comentários aqui
# ficam com o horário 12:00:00. Se houver mais de um comentário no mesmo
# dia, o script muda os segundos de cada um deles, para diferenciar e manter
# assim a sua ordem original.
#
# Para importar o arquivo XML no WordPress, acesse:
#     Ferramentas > Importar > WordPress
#
# Ele vai reclamar que não encontrou o autor do post, pode ignorar e mandar
# prosseguir. Será criado um post (ou página) com o nome que você definiu em
# $POST_NAME e nele estarão atrelados todos os comentários. Se você quiser
# mover todos ou somente alguns comentários para outro post ou página, use
# o plugin http://wordpress.org/extend/plugins/move-comments/
#
# Exemplo:
#
#   <dt>23/05/2005 <b title="verde (a) aurelio net">Aurélio Marinho Jargas</b> (Curitiba - PR)</dt><dd>
#   Valeu o toque Zé, coloquei uma observação e uns links da Wikipedia sobre o assunto também. Falou!</dd>
#
# vira:
#
# <wp:comment>
# <wp:comment_id>1</wp:comment_id>
# <wp:comment_author><![CDATA[Aurélio Marinho Jargas (Curitiba - PR)]]></wp:comment_author>
# <wp:comment_author_email>verde@aurelio.net</wp:comment_author_email>
# <wp:comment_author_url></wp:comment_author_url>
# <wp:comment_author_IP></wp:comment_author_IP>
# <wp:comment_date>2005-05-23 12:00:00</wp:comment_date>
# <wp:comment_approved>1</wp:comment_approved>
# <wp:comment_type></wp:comment_type>
# <wp:comment_parent>0</wp:comment_parent>
# <wp:comment_content><![CDATA[Valeu o toque Zé, coloquei uma observação e uns links da Wikipedia sobre o assunto também. Falou!]]></wp:comment_content>
# </wp:comment>



POST_TYPE="page"         # page, post
POST_STATUS="private"    # private, public
POST_NAME="A3"


cat <<EOS
<?xml version="1.0" encoding="UTF-8" ?>
<!-- This is a WordPress eXtended RSS file generated by WordPress as an export of your site. -->
<!-- It contains information about your site's posts, pages, comments, categories, and other content. -->
<!-- You may use this file to transfer that content from one site to another. -->
<!-- This file is not intended to serve as a complete backup of your site. -->

<!-- To import this information into a WordPress site follow these steps: -->
<!-- 1. Log in to that site as an administrator. -->
<!-- 2. Go to Tools: Import in the WordPress admin panel. -->
<!-- 3. Install the "WordPress" importer from the list. -->
<!-- 4. Activate & Run Importer. -->
<!-- 5. Upload this file using the form provided on that page. -->
<!-- 6. You will first be asked to map the authors in this export file to users -->
<!--    on the site. For each author, you may choose to map to an -->
<!--    existing user on the site or to create a new user. -->
<!-- 7. WordPress will then import each of the posts, pages, comments, categories, etc. -->
<!--    contained in this file into your site. -->

<!-- generator="WordPress/3.1" created="2011-03-30 18:45" -->
<rss version="2.0"
	xmlns:excerpt="http://wordpress.org/export/1.1/excerpt/"
	xmlns:content="http://purl.org/rss/1.0/modules/content/"
	xmlns:wfw="http://wellformedweb.org/CommentAPI/"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:wp="http://wordpress.org/export/1.1/"
>

<channel>
	<wp:wxr_version>1.1</wp:wxr_version>

	<item>
		<title>$POST_NAME</title>
		<wp:comment_status>open</wp:comment_status>
		<wp:post_type>$POST_TYPE</wp:post_type>
		<wp:status>$POST_STATUS</wp:status>

EOS



gsed -n '

# restore emails
/^<dt>/ {
	:email2
	# Change space to dot inside masked email, after (a)
	s/\((a) .[^"]*\) /\1./
	t email2

	:email1
	# Change space to dot inside masked email, before (a)
	s/\("[^" ]*\) \(.* (a)\)/\1.\2/
	t email1
	
	s/ (a) /@/

	# remove empty email
	s/<b title="-"/<b title=""/

	# remove empty country
	#/<b title="/ s|()</dt>|</dt>|

# Fix date from dd/mm/yyyy to yyyy-mm-dd
s|^<dt>\(..\)/\(..\)/\(....\)|<dt>\3-\2-\1|

# Fix no email
# <dt>10/05/2005 <b>Rudá Moura</b>  (Recife - PE)</dt><dd>
s/^\(<dt>....-..-.. <b\)>/\1 title="">/

# comment info
# <dt>2010-12-31 <b title="ahoooo (a) hotmail com">ricardo</b> (São Paulo - SP)</dt><dd>
s|^<dt>\(....-..-..\) <b title="\([^"]*\)">\(.*\)</b>  *(\(.*\) - \(.*\))</dt><dd>|\
<wp:comment>\
<wp:comment_id></wp:comment_id>\
<wp:comment_author><![CDATA[\3]]></wp:comment_author>\
<wp:comment_author_email>\2</wp:comment_author_email>\
<wp:comment_author_url></wp:comment_author_url>\
<wp:comment_author_IP></wp:comment_author_IP>\
<wp:comment_date>\1 12:00:00</wp:comment_date>\
<wp:comment_approved>1</wp:comment_approved>\
<wp:comment_type></wp:comment_type>\
<wp:comment_parent>0</wp:comment_parent>\
<wp:commentmeta>\
	<wp:meta_key>zzcidade</wp:meta_key>\
	<wp:meta_value><![CDATA[\4]]></wp:meta_value>\
</wp:commentmeta>\
<wp:commentmeta>\
	<wp:meta_key>zzestado</wp:meta_key>\
	<wp:meta_value><![CDATA[\5]]></wp:meta_value>\
</wp:commentmeta>|p

# <wp:comment_user_id>0</wp:comment_user_id>

# comment contents
n

:join

/<\/dd>/ {
	s|</dd>$||
	s|.*|<wp:comment_content><![CDATA[&]]></wp:comment_content>\
</wp:comment>|p
	n
	
	## Dump just the first entry or...
	# q
	## Dump all.
	b end
}

N
b join

:end
}


' | sed 's| ()\]\]></wp:comment_author>|]]></wp:comment_author>|' # Remove empty (Country)

cat <<EOS

</item>
</channel>
</rss>
EOS
