//
//  ViewController.swift
//  Onde Estou
//
//  Created by Treinamento on 9/19/19.
//  Copyright © 2019 JCAS. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapaViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet var endereco: UILabel!
    @IBOutlet var longitude: UILabel!
    @IBOutlet var latitude: UILabel!
    @IBOutlet var velocidade: UILabel!
    @IBOutlet var mapa: MKMapView!
    var gerenciadorLocal: CLLocationManager = CLLocationManager()
    var contadorErros = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gerenciadorLocal.delegate = self
        gerenciadorLocal.desiredAccuracy = kCLLocationAccuracyBest
        gerenciadorLocal.requestWhenInUseAuthorization()
        gerenciadorLocal.startUpdatingLocation()
    }
    
    
    //ATUALIZA AS INFORMAÇÕES DO USUÁRIO NA TELA.
    func atualizarLocalizacao(latitude: String, longitude: String, velocidade: String) {
        self.longitude.text? = longitude
        self.latitude.text? = latitude
        self.velocidade.text? = "\(velocidade) Km/h"
    }
    
     //ATUALIZA AS INFORMAÇÕES DO USUÁRIO NA TELA.
    func atualizarEndereco(endereco: String){
        self.endereco.text = endereco
    }
    
    //CONVERTENDO OS NÚMEROS E CALCULANDO A VELOCIDADE EM QUILÔMETROS POR HORA.
    func calculadoraVelocidade(velocidadeUsuario: Double) -> String {
        let calcVelocidade = velocidadeUsuario * 1.61
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .none
        let formattedNumber = numberFormatter.string(from: NSNumber(value:calcVelocidade))
        let velocidadeString = String(formattedNumber!)
        
        if calcVelocidade < 9 {
            self.velocidade.frame.size.width = 80
            self.velocidade.frame.size.height = 80
            self.velocidade.layer.cornerRadius = 40
        }
        else if calcVelocidade > 99 {
            self.velocidade.frame.size.width = 110
            self.velocidade.frame.size.height = 110
            self.velocidade.layer.cornerRadius = 55
        }
        else {
            self.velocidade.frame.size.width = 90
            self.velocidade.frame.size.height = 90
            self.velocidade.layer.cornerRadius = 45
        }
        
        return velocidadeString
    }
    
    
    //ATUALIZANDO A POSICAO DO USUARIO.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let localizacaoUsuario = locations.last {
            let latitude: CLLocationDegrees = localizacaoUsuario.coordinate.latitude
            let longitude: CLLocationDegrees = localizacaoUsuario.coordinate.longitude
            let localizacao: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let deltaLatitude: CLLocationDegrees = 0.004
            let deltaLongitude: CLLocationDegrees = 0.004
            let areaVisualizacao: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: deltaLatitude, longitudeDelta: deltaLongitude)
            
            let regiao = MKCoordinateRegion(center: localizacao, span: areaVisualizacao)
            self.mapa.setRegion(regiao, animated: true)
            
            //Convertendo as coordenadas em strings acessível pelo campo de texto.
            let latitudeString = String(latitude)
            let longitudeString = String(longitude)
            
            //Obtendo a velocidade do usuário.
            let velocidadeUsuario = localizacaoUsuario.speed
            let velocidadeString = calculadoraVelocidade(velocidadeUsuario: velocidadeUsuario)
            
            //Obtendo o endereço.
            
            CLGeocoder().reverseGeocodeLocation(localizacaoUsuario) { (detalhes, error) in
                if error == nil {
                    if let dados = detalhes?.first {
                        let endereco = dados.thoroughfare ?? "Indisponível"
                        let enderecoN = dados.subThoroughfare ?? ""
                        let localidade = dados.locality ?? ""
                        
                        let enderecoString = String(endereco + ", " + enderecoN + " - " + localidade)
                        self.atualizarEndereco(endereco: enderecoString)
                        self.contadorErros = 1
                    }
                }
                else {
                    self.contadorErros += 1
                    print("Falha ao obter os dados do seu endereço: \(self.contadorErros)")
                }
            }
            
            atualizarLocalizacao(latitude: latitudeString, longitude: longitudeString, velocidade: velocidadeString)
        }
    }
}

