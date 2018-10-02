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
        -v $HOME/.m2:/.m2 
        -v $HOME/.gitconfig:/.gitconfig
        -v $HOME/ld-config:/ld-config
        """
        
        dispatchImage.inside(options) {
            sh 'mvn clean deploy'
        }
    }
}