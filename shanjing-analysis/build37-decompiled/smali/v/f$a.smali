.class Lv/f$a;
.super Landroid/net/ConnectivityManager$NetworkCallback;
.source "SourceFile"


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lv/f;->c(Ljava/lang/Object;Lj0/d$b;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic a:Lv/f;


# direct methods
.method constructor <init>(Lv/f;)V
    .locals 0

    iput-object p1, p0, Lv/f$a;->a:Lv/f;

    invoke-direct {p0}, Landroid/net/ConnectivityManager$NetworkCallback;-><init>()V

    return-void
.end method


# virtual methods
.method public onAvailable(Landroid/net/Network;)V
    .locals 0

    iget-object p1, p0, Lv/f$a;->a:Lv/f;

    invoke-static {p1}, Lv/f;->e(Lv/f;)V

    return-void
.end method

.method public onLost(Landroid/net/Network;)V
    .locals 1

    iget-object p1, p0, Lv/f$a;->a:Lv/f;

    const-string v0, "none"

    invoke-static {p1, v0}, Lv/f;->f(Lv/f;Ljava/lang/String;)V

    return-void
.end method
