# FSS-Stack-Deploy-Automatizado
Conseguir <a href="https://cloudone.trendmicro.com/docs/file-storage-security/api-create-stack/"> automaticamente </a> dar o deploy da Stack All-in-One do File Storage Security em uma conta da AWS!

<hr />
<br />

## Para usar:

<br />

### Para usar na sua máquina:

<br />

<b> De um git clone ou baixe o zip para a sua máquina: </b>

<ul>

<li> No <strong> fss-stack-deploy.sh </strong> mude as variáveis para de acordo com o seu ambiente. </li>
<li> Execute o arquivo. </li>
<li> Caso queira, pode conferir nas consoles da AWS - CloudFormation e Cloud One File Storage Security os recursos sendo criados. </li>

</ul>

<br />
<hr />
<br />

### Para usar no Github Actions:

<br />

<b> De um fork no repositório. </b>

<b> No <a href="https://docs.github.com/pt/actions/reference/encrypted-secrets"> secrets </a> do seu repositório, crie as seguintes variáveis: </b>

<ul>  

<li> externalid </li>
    <ul> <li> External ID Obtido. Para pegar o ExternalID, precisa fazer uma chamada para a <a href="https://cloudone.trendmicro.com/docs/file-storage-security/api-reference/#operation/describeExternalID"> API do FSS.</a>  </li> </ul>
<li> allinone_stackname </li>
    <ul> <li> O nome do Deploy da sua All In One Stack do FSS </li> </ul>
<li> region </li>
    <ul> <li> Região que você quer instalar a Stack </li> </ul>
<li> s3bucket_to_scan </li>
    <ul> <li> O Nome do Seu Bucket-to-scan <strong> *Esse bucket já precisa existir* </strong> </li> </ul>
<li> kmsmaster_key_arn </li>
    <ul> <li> A sua Master Key do KMS na qual é usado para encriptar objetos no seu bucket-to-scan do S3. Deixe em branco se você não habilitou o SSE-KMS no seu bucket. </li> </ul>
<li> kmsmaster_key_arn_for_sqs </li>
    <ul> <li>  A sua chave mestra do KMS na qual é usado para encriptar as mensagens no SQS no seu scanner-stack. Deixe em branco se você não habilitou o SSE-KMS.  </li> </ul>
<li> c1_api_key </li>
    <ul> <li> A sua API do Cloud One </li> </ul>

</ul>

### OBS:

Também é necessário manualmente abrir o arquivo <b> fss-automates-deploy.yml </b> e nesse arquivo ir para o <b> Step com nome: AWS Credentials. </b> E lá, mudar na variável <b> aws-region </b> para a sua região.  

<hr />
<br />

## Próximos Passos:

<br />

<b> Para saber mais como testar o Cloud One File Storage Security: 
<a href="https://github.com/SecurityForCloudBuilders/SegurancaParaNuvem/tree/main/SegurancaParaCloudESecOps/SeguracaParaFileStorage"> SeguracaParaFileStorage. </a> 

Ou os outros módulos para ajudar na sua jornada de construção de Segurança na Cloud: <a href="https://github.com/SecurityForCloudBuilders/SegurancaParaNuvem"> SegurancaParaNuvem. </a></b>

<br />

<i> <strong> Sinta-se livre para também contribuir! </i> </strong>
