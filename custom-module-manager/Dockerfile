FROM quadstingray/webtrees:2.2.6

ENV CUSTOM_MODULE_MANAGER_VERSION="2.0.5"

WORKDIR /tmp_download

ADD https://github.com/Jefferson49/CustomModuleManager/releases/download/v${CUSTOM_MODULE_MANAGER_VERSION}/custom_module_manager_v${CUSTOM_MODULE_MANAGER_VERSION}.zip custom_module_manager.zip

RUN php -r '$zip = new ZipArchive(); $zip->open("custom_module_manager.zip") === true && $zip->extractTo("/var/www/html/modules_v4/") || exit(1);'
RUN chown -R www-data:www-data /var/www/html/modules_v4 && chmod -R u+rwX,g+rwX,o-w /var/www/html/modules_v4
RUN rm -rf /tmp_download

WORKDIR /var/www/html

EXPOSE 80

ENTRYPOINT ["/scripts/entrypoint.sh"]
