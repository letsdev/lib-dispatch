node('docker') {

    def dispatchImage
    stage('Prepare') {
        deleteDir()
        checkout scm
        dispatchImage = docker.build('dispatch')
    }

    stage('build & deploy') {
        def options = """
        -v $WORKSPACE:/app 
        -v $HOME/.m2:/root/.m2 
        -v $HOME/.gitconfig:/root/.gitconfig
        -v $HOME/ld-config:/root/ld-config
        """
        
        dispatchImage.inside(options) {
            sh 'mvn clean deploy'
        }
    }
}