<template>
  <div>
    <v-layout
      row
      wrap
    >
      <v-flex
        xs12
        sm12
        md12
      >
        <h1 class="titile">
          ビデオ配信(1対多,P2P)
        </h1>
      </v-flex>
    </v-layout>
    <v-card class="mx-2 my-2">
      <v-form @submit.prevent="makeBroadcast">
        <v-container>
          <v-layout
            row
            wrap
          >
            <v-flex
              xs12
              sm12
              md12
            >
              <h2 class="headline">
                配信
              </h2>
            </v-flex>
            <v-flex
              xs12
              sm12
              md12
            >
              <v-text-field
                v-model="peerId"
                label="Peer ID"
                :readonly="true"
              />
            </v-flex>
            <v-flex
              xs12
              sm12
              md6
            >
              <v-select
                v-model="selectedAudio"
                :items="audios"
                label="オーディオ"
                @change="changeAudioVideo"
              />
            </v-flex>
            <v-flex
              xs12
              sm12
              md6
            >
              <v-select
                v-model="selectedVideo"
                :items="videos"
                label="ビデオ"
                @change="changeAudioVideo"
              />
            </v-flex>
          </v-layout>
        </v-container>
        <v-flex
          v-if="broadcastStream"
          xs12
          sm12
          md12
        >
          <v-card class="mx-2 my-2">
            <video
              ref="broadcastVideo"
              class="video"
              muted="true"
              autoplay
              playsinline
            />
          </v-card>
        </v-flex>
        <v-card-actions>
          <v-spacer />
          <v-btn color="primary" type="submit">
            配信
          </v-btn>
        </v-card-actions>
      </v-form>
    </v-card>
    <v-card class="mx-2 my-2">
      <v-form @submit.prevent="makeReceive">
        <v-container>
          <v-layout
            row
            wrap
          >
            <v-flex
              xs12
              sm12
              md12
            >
              <h2 class="headline">
                受信
              </h2>
            </v-flex>
            <v-flex
              xs12
              sm12
              md12
            >
              受信先のPeer IDを入力して接続してください。
            </v-flex>
            <v-flex
              xs12
              sm12
              md12
            >
              <v-text-field
                v-model="receivePeerId"
                label="Receive Peer ID"
              />
            </v-flex>
          </v-layout>
        </v-container>
        <v-flex
          v-if="receiveStream"
          xs12
          sm12
          md12
        >
          <v-card class="mx-2 my-2">
            <video
              ref="receiveVideo"
              class="video"
              autoplay
              playsinline
            />
          </v-card>
        </v-flex>
        <v-card-actions>
          <v-spacer />
          <v-btn color="primary" type="submit">
            接続
          </v-btn>
          <v-btn @click="endReceive">
            切断
          </v-btn>
        </v-card-actions>
      </v-form>
    </v-card>
  </div>
</template>

<script>
/* eslint-disable no-console */
import Peer from 'skyway-js'

export default {
  data() {
    return {
      peer: null,
      selectedAudio: '',
      selectedVideo: '',
      audios: [],
      videos: [],
      broadcastStream: null,
      receiveStream: null,
      peerId: '',
      receivePeerId: '',
      call: null
    }
  },
  mounted() {
    // オーディオ・ビデオデバイスの準備
    this.prepareAudioVideoDevice()

    // Peerオブジェクトの作成
    this.peer = new Peer({ key: process.env.API_KEY, debug: 3 })

    // 接続成功・失敗・切断時のイベント設定
    this.peer.on('open', () => {
      console.log(`peer event open: peer.id=${this.peer.id}`)
      this.peerId = this.peer.id
    })
    this.peer.on('error', err => {
      console.error(`peer event error:`, err)
    })
    this.peer.on('disconnected', () => {
      console.log(`peer event disconnected`)
    })

    // 着信のイベント設定
    this.peer.on('call', call => {
      console.log(`peer event call`)
      call.answer(this.broadcastStream)
    })
  },
  methods: {
    // オーディオ・ビデオデバイスを準備
    prepareAudioVideoDevice: function() {
      navigator.mediaDevices.enumerateDevices().then(deviceInfos => {
        const audios = [{ text: '指定なし', value: '' }]
        const videos = [{ text: '指定なし', value: '' }]

        for (let i = 0; i !== deviceInfos.length; ++i) {
          const deviceInfo = deviceInfos[i]
          if (deviceInfo.kind === 'audioinput') {
            audios.push({
              text: deviceInfo.label || `Microphone ${this.audios.length + 1}`,
              value: deviceInfo.deviceId
            })
          } else if (deviceInfo.kind === 'videoinput') {
            videos.push({
              text: deviceInfo.label || `Camera  ${this.videos.length - 1}`,
              value: deviceInfo.deviceId
            })
          }
        }

        this.audios = audios
        this.videos = videos
      })
    },
    // オーディオ・ビデオの変更
    changeAudioVideo: function() {
      this.$nextTick(() => {
        this.connectLocalCamera()
      })
    },
    // ローカルカメラに接続
    connectLocalCamera: function() {
      const constraints = {
        audio:
          this.selectedAudio !== ''
            ? { deviceId: { exact: this.selectedAudio } }
            : true,
        video:
          this.selectedVideo !== ''
            ? { deviceId: { exact: this.selectedVideo } }
            : true
      }

      navigator.mediaDevices
        .getUserMedia(constraints)
        .then(stream => {
          this.prepareAudioVideoDevice()
          this.broadcastStream = stream
          this.$nextTick(() => {
            this.$refs.broadcastVideo.srcObject = stream
          })
        })
        .catch(err => {
          console.error('mediaDevice.getUserMedia() error:', err)
        })
    },
    // 配信
    makeBroadcast: function() {
      this.connectLocalCamera()
    },
    // 受信
    makeReceive: function() {
      const call = this.peer.call(this.receivePeerId)
      this.connectCall(call)
    },
    // 接続
    connectCall: function(call) {
      this.endReceive()
      call.on('stream', stream => {
        this.receiveStream = stream
        this.$nextTick(() => {
          this.$refs.receiveVideo.srcObject = stream
          this.$refs.receiveVideo.play()
        })
      })
      this.call = call
    },
    // 切断
    endReceive: function() {
      if (this.call) {
        this.call.close()
        this.call = null
      }
    }
  }
}
/* eslint-enable no-console */
</script>

<style lang='scss' scoped>
.video {
  width: 100%;
  height: 100%;
}
</style>
