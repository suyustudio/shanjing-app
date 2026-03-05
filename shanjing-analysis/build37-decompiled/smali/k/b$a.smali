.class Lk/b$a;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Lcom/amap/api/maps/AMap$OnMapScreenShotListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lk/b;->f(Lj0/j;Lj0/k$d;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic a:Lj0/k$d;

.field final synthetic b:Lk/b;


# direct methods
.method constructor <init>(Lk/b;Lj0/k$d;)V
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    iput-object p1, p0, Lk/b$a;->b:Lk/b;

    iput-object p2, p0, Lk/b$a;->a:Lj0/k$d;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method
