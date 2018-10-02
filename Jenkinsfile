node('docker') {

    def dispatchImage
    stage('Prepare') {
        deleteDir()
        checkout scm
        dispatchImage = docker.build('dispatch')
    }

    stage('build & deploy') {
        def options = """
        -v $WORKSPACE:/home/build/app 
        -v $HOME/.m2:/home/build/.m2 
        -v $HOME/.gitconfig:/home/build/.gitconfig
        -v $HOME/ld-config:/home/build/ld-config
        """
        
        dispatchImage.inside(options) {
            sh 'mvn clean deploy'
        }
    }
}