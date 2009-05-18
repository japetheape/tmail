# encoding: utf-8
require 'test_helper'
require 'tmail'

class TestAttachments < Test::Unit::TestCase

  def test_attachment
    mail = TMail::Mail.new
    mail.mime_version = "1.0"
    mail.set_content_type 'multipart', 'mixed', {'boundary' => 'Apple-Mail-13-196941151'}
    mail.body =<<HERE
--Apple-Mail-13-196941151
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=ISO-8859-1;
	delsp=yes;
	format=flowed

This is the first part.

--Apple-Mail-13-196941151
Content-Type: text/x-ruby-script; name="hello.rb"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="api.rb"

puts "Hello, world!"
gets

--Apple-Mail-13-196941151--
HERE
    assert_equal(true, mail.multipart?)
    assert_equal(1, mail.attachments.length)
  end
  
  def test_recursive_multipart_processing
    fixture = File.read(File.dirname(__FILE__) + "/fixtures/raw_email7")
    mail = TMail::Mail.parse(fixture)
    assert_equal "This is the first part.\n\nAttachment: test.rb\nAttachment: test.pdf\n\n\nAttachment: smime.p7s\n", mail.body
  end

  def test_decode_encoded_attachment_filename
    fixture = File.read(File.dirname(__FILE__) + "/fixtures/raw_email8")
    mail = TMail::Mail.parse(fixture)
    attachment = mail.attachments.last
    expected = "01 Quien Te Dij\212at. Pitbull.mp3"
    expected.force_encoding "BINARY" if expected.respond_to? :force_encoding
    assert_equal expected, attachment.original_filename
  end

  def test_attachment_with_quoted_filename
    fixture = File.read(File.dirname(__FILE__) + "/fixtures/raw_email_with_quoted_attachment_filename")
    mail = TMail::Mail.parse(fixture)
    attachment = mail.attachments.last
    assert_equal "Eelanalüüsi päring.jpg", attachment.original_filename
  end

  def test_assigning_attachment_crashing_due_to_missing_boundary
    mail = TMail::Mail.new  
    mail.mime_version = '1.0'
    mail.set_content_type("multipart", "mixed")
    
    mailpart=TMail::Mail.new
    mailpart.set_content_type("application", "octet-stream")
    mailpart['Content-Disposition'] = "attachment; filename=mailbox.zip"

    assert_nothing_raised { mail.parts.push(mailpart) }
  end
  
  def test_only_has_attachment
    fixture = File.read(File.dirname(__FILE__) + "/fixtures/raw_email_only_attachment")
    mail = TMail::Mail.parse(fixture)
    assert_equal(1, mail.attachments.length)
  end
  
end
