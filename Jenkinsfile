node('docker') {

    def dispatchImage
    stage('Prepare') {
        deleteDir()
        checkout scm
        dispatchImage = docker.build('dispatch')
    }

    stage('build & deploy') {
        def options = """
        --privileged 
        -v $WORKSPACE:/app 
        -v $HOME/.m2:/home/jenkins/.m2 
        -v $HOME/.gitconfig:/home/jenkins/.gitconfig
        -v $HOME/ld-config:/home/jenkins/ld-config
        """
        
        dispatchImage.inside(options) {
            sh 'mvn deploy'
        }
    }
}