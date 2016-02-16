class PetitionMailer < ApplicationMailer
  default from: 'bounces@petities.nl', reply_to: 'webmaster@petities.nl'

  # ask signatories with any pledge to adopt orphaned petition
  # rake petition:find_new_owner
  def adoption_request_signatory_mail(petition, signature)
    @signature = signature
    @petition = petition
    @become_owner_url = url_for(
      controller: 'signatures',
      action: 'become_petition_owner',
      signature_id: @signature.unique_key)
    subject = t('mail.petition.adoption_request_subject', petition: petition.name)
    mail(to: @signature.person_email, subject: subject)
  end

  # ask office which date petition should get an answer
  # rake petitions:handle_overdue_petitions
  def ask_office_answer_due_date_mail(petition)
    @petition = petition
    subject = t('mail.request.due_date_subject', petition: petition.name)
    mail(reply_to: subdomain_address(@petition), to: @petition.office.email,
         subject: subject)
  end

  # ask office for answer to petition
  # rake petition:get_anwer_from_office
  def ask_office_for_answer_mail(petition)
    @petition = petition

    subject = t('mail.request.answer_subject', petition: petition.name)
    mail(reply_to: subdomain_address(@petition), to: @petition.office.email,
         subject: subject)
  end

  # call petitioner into action about closing petition
  # rake petition:send_warning_due_date
  def due_next_week_warning_mail(petition)
    @petition = petition
    subject = t('mail.petition.due_next_week_subject', petition: petition.name)
    mail(to: petition.petitioner_email, subject: subject)
  end

  # finalize petition, ready for moderation
  def finalize_mail(petition, target: nil)
    @petition = petition
    target = @petition.office.email if target.nil?

    tld = get_tld(target)

    I18n.with_locale(tld) do
      subject = t('mail.moderation.pending_subject', petition: petition.name)

      mail(to: target, subject: subject)
    end
  end

  # a virtual hand over of the signatories list
  def hand_over_to_office_mail(petition)
    @petition = petition
    target = @petition.office.email
    subject = t('mail.request.procedural_subject', petition: petition.name)
    mail(reply_to: subdomain_address(@petition), to: target, subject: subject)
  end

  # petitioner with failed petition asked to fix it
  def improve_and_reopen_mail(petition)
    @petition = petition
    subject = t('mail.petition.improve_and_reopen_subject', petition: petition.name)

    mail(to: petition.petitioner_email, subject: subject)
  end

  # announce petition to office
  def petition_announcement_mail(petition)
    @petition = petition
    target = @petition.office.email

    tld = get_tld(target)

    I18n.with_locale(tld) do
      subject = t('mail.request.announcement_subject')
      mail(reply_to: subdomain_address(@petition), to: target, subject: subject)
    end
  end

  # explain office what we expect
  def process_explanation_mail(petition)
    @petition = petition
    target = @petition.office.email
    subject = t('mail.request.procedural_subject', petition: petition.name)
    mail(from: 'webmaster@petities.nl', reply_to: subdomain_address(@petition),
         to: target, subject: subject)
  end

  # ask office for reference number
  def reference_number_mail(petition)
    logger.debug('building reference number mail..')
    @petition = petition
    subject = t('mail.request.reference_subject', petition: petition.name)
    mail(from: 'webmaster@petities.nl', reply_to: subdomain_address(@petition),
         to: @petition.office.email, subject: subject)
  end

  # each petition status change by e-mail to admin
  def status_change_mail(petition, target: nil)
    @petition = petition

    subject = t('mail.status.changed_subject',
                petition: petition.name,
                status: petition.status) +
                t("show.overview.status.#{@petition.state_summary}")

    # NOTE petitioner_email can be wrong?
    # should we not send email to admin users?
    target = @petition.petitioner_email if target.nil?

    if target
      mail(from: 'webmaster@petities.nl', to: target, subject: subject)
    end
  end

  # petitioner is asked to write an update about the hand over
  def write_about_hand_over_mail(petition)
    @petition = petition
    subject = t('mail.petition.write_about_hand_over_subject', petition_name: petition.name)

    mail(reply_to: 'webmaster@petities.nl', to: petition.petitioner_email,
         subject: subject)
  end

  # ask petitioner to confirm, give user and password
  def welcome_petitioner_mail(petition, user, password, target: nil)
    @petition = petition
    @user = user
    @password = password

    if petition.office.nil?
      @office_email = 'petition has no office'
      @office_telephone = 'petition has no office'
    else
      @office_email = petition.office.email || 'office has no email set'
      @office_telephone = petition.office.telephone || 'office has not telephone set'
    end

    # NOTE petitioner_email can be wrong?
    # should we not send email to admin users?
    target = @user.email if target.nil?

    tld = get_tld(target)

    I18n.with_locale(tld) do
      subject = t('mail.petition.confirm.subject', petition_name: petition.name)
      mail(from: 'webmaster@petities.nl', to: target, subject: subject)
    end
  end

  private

  def get_tld(target)
    locale = :nl
    tld = target.split('.').last
    locale = tld if I18n.available_locales.include? tld.to_sym
    locale
  end

  def subdomain_address(petition)
    "#{petition.subdomain}@petities.nl"
  end
end
