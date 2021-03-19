# FSS-Stack-Deploy-Automatizado
Conseguir <a href="https://cloudone.trendmicro.com/docs/file-storage-security/api-create-stack/"> automaticamente </a> dar o deploy da Stack All-in-One do File Storage Security em uma conta da AWS!

<hr />

## Para usar no Github Actions:

<br />

<b> De um fork nesse repositório. </b>

<b> No <a href="https://docs.github.com/pt/actions/reference/encrypted-secrets"> secrets </a> do seu repositório, crie as seguintes variáveis: </b>

<ul>  

<li> allinone_stackname </li>
    <ul> <li> O nome do Deploy da sua All In One Stack do FSS </li> </ul>
<li> region </li>
    <ul> <li> Região que você quer instalar a Stack </li> </ul>
<li> s3bucket_to_scan </li>
    <ul> <li> O Nome do Seu Bucket-to-scan <strong> <b> *Se um bucket com esse nome não existir, ele irá ser criado. * </b> </strong> </li> </ul>
<li> kmsmaster_key_arn </li>
    <ul> <li> A sua Master Key do KMS na qual é usado para encriptar objetos no seu bucket-to-scan do S3. Deixe em branco se você não habilitou o SSE-KMS no seu bucket. </li> </ul>
<li> kmsmaster_key_arn_for_sqs </li>
    <ul> <li>  A sua chave mestra do KMS na qual é usado para encriptar as mensagens no SQS no seu scanner-stack. Deixe em branco se você não habilitou o SSE-KMS.  </li> </ul>
<li> aws_access_key_id </li>
    <ul> <li> A Access Key ID do seu usuário que pertence a sua conta da AWS  </ul> </li>
<li> aws_secret_access_key </li> 
    <ul> <li> O Secret Access Key do seu usuário que pertence a sua conta da AWS </ul> </li>
<li> c1_api_key </li>
    <ul> <li> A sua API do Cloud One </li> </ul>

</ul>

<br />

### Post-Actions Workflow

Caso quiera utilizar o <b> "Post-Action-Automated-Deploy" </b>, crie as seguintes variáveis no Secret do seu Repositório:

<ul> 

<li> allinone_stackname </li>
    <ul> <li> O nome do Deploy da sua All In One Stack do FSS. </li> </ul>
<li> bucket_to_promote_name </li>
    <ul> <li> Será o nome do bucket que receberá os arquivos considerados pelo FSS como limpos. <b> *Se um bucket com esse nome não existir, ele irá ser criado. * </b> </li> </ul> 
<li> bucket_to_quarantine_name </li>
    <ul> <li> Será o nome do bucket que receberá os arquivos que o FSS julga que devem ser quarentenados. <b> *Se um bucket com esse nome não existir, ele irá ser criado. * </b> </li> </ul> 
<li> function_name </li>
    <ul> <li> Nome da Lambda function que será criada. </li> </ul> 
<li> bucket_to_scan_arn </li> 
    <ul> <li> O nome do seu Bucket que será escaneado. <b> *Já precisa existir/ ter sido criado pelo o Deployment Stack do FSS.* </b> </ul> </li>
    <ul> <li> <strong> ! IMPORTANTE: ! Essa variável deve seguir o seguinte formato: arn:aws:s3:::YOUR_BUCKET_TO_SCAN_NAME_HERE/* </strong> </ul> </li>
<li> bucket_to_promote_arn </li>
    <ul> <li> O nome do seu Bucket-To-Promote. </ul> </li>
    <ul> <li> <strong>  ! IMPORTANTE: ! Essa variável deve seguir o seguinte formato: arn:aws:s3:::YOUR_QUARANTINE_BUCKET_NAME_HERE/* </strong> </ul> </li>
<li> bucket_to_quarantine_arn </li>
    <ul> <li> O nome do seu Bucket-To-Quarantine. </ul> </li>
    <ul> <li> <strong> ! IMPORTANTE: ! Essa variável deve seguir o seguinte formato: arn:aws:s3:::YOUR_PROMOTE_BUCKET_NAME_HERE/* </strong> </ul> </li> 

</ul>

<br />

### IMPORTANTE:

Também é necessário manualmente abrir o arquivo <b> fss-automated-deploy.yml </b> e/ ou <b> fss-post-action.yml </b> (caso queira utilizar o "Post-Action-Automated-Deploy" Workflow) e nesse arquivo ir para o <b> Step com nome: AWS Credentials. </b> E lá, mudar na variável <b> aws-region </b> para a sua região.  

<b> E finalmente, vá até a parte de Actions no Seu Repositório. Embaixo de "All Workflows" procure e clique em "FSS-Automated-Deploy". Por último, clique em "Run workflow". 

Ou no caso para executar o "Post-Action-Automated-Deploy", embaixo de "All Workflows" procure e clique em "Post-Action-Automated-Deploy". Por último, clique em "Run workflow"

Pronto, o Workflow irá começar automaticamente!</b>

<br />
<hr />
<br />

## Caso não quiera usar o Github Action:

<br />

<b> De um git clone ou baixe o zip para a sua máquina: </b>

<ul>

<li> No <strong> fss-stack-deploy.sh </strong> e/ ou <strong> fss-post-actions.sh </strong> mude as variáveis para de acordo com o seu ambiente. </li>
<li> Execute o arquivo. </li>
<li> Caso queira, pode conferir nas consoles da AWS - CloudFormation e Cloud One File Storage Security os recursos sendo criados. </li>

</ul>

<br />
<hr />
<br />

## Próximos Passos:

<br />

<b> Para saber mais como testar o Cloud One File Storage Security: 
<a href="https://github.com/SecurityForCloudBuilders/SegurancaParaNuvem/tree/main/SegurancaParaCloudESecOps/SeguracaParaFileStorage"> SeguracaParaFileStorage. </a> 

Ou outras ferramentas para ajudar na sua jornada de construção de Segurança na Cloud: <a href="https://github.com/SecurityForCloudBuilders/SegurancaParaNuvem"> SegurancaParaNuvem. </a></b>

<br />